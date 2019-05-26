#!/bin/bash

set -e

if [ "$1" = 'standalone.sh' ]; then

    # usage: file_env VAR [DEFAULT]
    #    ie: file_env 'XYZ_DB_PASSWORD' 'example'
    # (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
    #  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
    file_env() {
        local var="$1"
        local fileVar="${var}_FILE"
        local def="${2:-}"
        if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
            echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
            exit 1
        fi
        local val="$def"
        if [ "${!var:-}" ]; then
            val="${!var}"
        elif [ "${!fileVar:-}" ]; then
            val="$(< "${!fileVar}")"
        fi
        export "$var"="$val"
        unset "$fileVar"
    }

    file_env 'LDAP_ROOTPASS' 'secret'
    file_env 'KEYCLOAK_DB_USER' 'keycloak'
    file_env 'KEYCLOAK_DB_PASSWORD' 'keycloak'
    file_env 'KEYCLOAK_USER'
    file_env 'KEYCLOAK_PASSWORD'
    file_env 'KEYSTORE_PASSWORD' 'secret'
    file_env 'KEY_PASSWORD' "${KEYSTORE_PASSWORD}"
    file_env 'TRUSTSTORE_PASSWORD' 'secret'

    # Append '?' in the beginning of the string if KEYCLOAK_DB_JDBC_PARAMS value isn't empty
    KEYCLOAK_DB_JDBC_PARAMS=$(echo ${KEYCLOAK_DB_JDBC_PARAMS} | sed '/^$/! s/^/?/')

    if [ ! -d $JBOSS_HOME/standalone/configuration ]; then
        cp -r /docker-entrypoint.d/deployments $JBOSS_HOME/standalone
        cp -r /docker-entrypoint.d/configuration $JBOSS_HOME/standalone
        sed -e "s%\${env.REALM_NAME}%${REALM_NAME:-dcm4che}%" \
            -e "s%\${env.LDAP_BASE_DN}%${LDAP_BASE_DN}%" \
            -e "s%\${env.LDAP_URL}%${LDAP_URL}%" \
            -e "s%\${env.LDAP_ROOTPASS}%${LDAP_ROOTPASS}%" \
            -e "s%\${env.SSL_REQUIRED}%${SSL_REQUIRED:-external}%" \
            -e "s%\${env.VALIDATE_PASSWORD_POLICY}%${VALIDATE_PASSWORD_POLICY:-false}%" \
            -i $JBOSS_HOME/standalone/configuration/dcm4che-realm.json
        if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
            $JBOSS_HOME/bin/add-user-keycloak.sh -u $KEYCLOAK_USER -p $KEYCLOAK_PASSWORD
        fi
        chown -R keycloak:keycloak $JBOSS_HOME/standalone
    fi

    if [ ! -f $JAVA_HOME/lib/security/cacerts.done ]; then
        touch $JAVA_HOME/lib/security/cacerts.done
        if [ $TRUSTSTORE ]; then
            keytool -importkeystore \
                -srckeystore $TRUSTSTORE -srcstorepass $TRUSTSTORE_PASSWORD \
                -destkeystore $JAVA_HOME/lib/security/cacerts -deststorepass changeit
        fi
    fi

    if [ $KEYCLOAK_DB_HOST ]; then
        if [ $LOGSTASH_HOST ]; then
            SERVER_CONFIG=keycloak-logstash-psql.xml
        else
            SERVER_CONFIG=keycloak-psql.xml
        fi
    else
        if [ $LOGSTASH_HOST ]; then
            SERVER_CONFIG=keycloak-logstash.xml
        else
            SERVER_CONFIG=keycloak.xml
        fi
    fi
    BIND="-b 0.0.0.0 -bmanagement 0.0.0.0 -bprivate $(hostname -i)"

    for c in $KEYCLOAK_WAIT_FOR; do
        echo -n "Waiting for $c ... "
        while ! nc -w 1 -z ${c/:/ }; do sleep 1; done
        echo "done"
    done
    set -- gosu keycloak "$@" -c $SERVER_CONFIG $BIND -Dkeycloak.import=$KEYCLOAK_IMPORT
    echo "Starting Keycloak $KEYCLOAK_VERSION"
fi

exec "$@"
