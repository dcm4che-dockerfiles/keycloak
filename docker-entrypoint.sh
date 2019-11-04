#!/bin/bash

set -e

if [ "$1" = 'standalone.sh' ]; then

    . setenv.sh

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

    for c in $KEYCLOAK_WAIT_FOR; do
        echo "Waiting for $c ..."
        while ! nc -w 1 -z ${c/:/ }; do sleep 1; done
        echo "done"
    done
    set -- gosu keycloak "$@" $SYS_PROPS
    echo "Starting Keycloak $KEYCLOAK_VERSION"
fi

exec "$@"
