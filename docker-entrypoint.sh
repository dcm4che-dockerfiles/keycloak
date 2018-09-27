#!/bin/bash

set -e

if [ "$1" = 'standalone.sh' ]; then

    if [ -f $LDAP_ROOTPASS_FILE ]; then
        LDAP_ROOTPASS=`cat $LDAP_ROOTPASS_FILE`
    else
        echo $LDAP_ROOTPASS > $LDAP_ROOTPASS_FILE
    fi

    if [ -f $KEYCLOAK_ADMIN_PASSWORD_FILE ]; then
        KEYCLOAK_ADMIN_PASSWORD=`cat $KEYCLOAK_ADMIN_PASSWORD_FILE`
    elif [ -n "$KEYCLOAK_ADMIN_PASSWORD" ]; then
        echo $KEYCLOAK_ADMIN_PASSWORD > $KEYCLOAK_ADMIN_PASSWORD_FILE
    fi

    if [ -f $KEYSTORE_PASSWORD_FILE ]; then
        KEYSTORE_PASSWORD=`cat $KEYSTORE_PASSWORD_FILE`
    else
        echo $KEYSTORE_PASSWORD > $KEYSTORE_PASSWORD_FILE
    fi

    if [ -f $KEY_PASSWORD_FILE ]; then
        KEY_PASSWORD=`cat $KEY_PASSWORD_FILE`
    else
        echo $KEY_PASSWORD > $KEY_PASSWORD_FILE
    fi

    if [ -f $TRUSTSTORE_PASSWORD_FILE ]; then
        TRUSTSTORE_PASSWORD=`cat $TRUSTSTORE_PASSWORD_FILE`
    else
        echo $TRUSTSTORE_PASSWORD > $TRUSTSTORE_PASSWORD_FILE
    fi

    if [ ! -d $JBOSS_HOME/standalone/configuration ]; then
        cp -r /docker-entrypoint.d/deployments $JBOSS_HOME/standalone
        cp -r /docker-entrypoint.d/configuration $JBOSS_HOME/standalone
        sed -e "s%\${env.REALM_NAME}%${REALM_NAME}%" \
            -e "s%\${env.LDAP_BASE_DN}%${LDAP_BASE_DN}%" \
            -e "s%\${env.LDAP_URL}%${LDAP_URL}%" \
            -e "s%\${env.LDAP_ROOTPASS}%${LDAP_ROOTPASS}%" \
            -e "s%\${env.SSL_REQUIRED}%${SSL_REQUIRED}%" \
            -e "s%\${env.VALIDATE_PASSWORD_POLICY}%${VALIDATE_PASSWORD_POLICY}%" \
            -i $JBOSS_HOME/standalone/configuration/dcm4che-realm.json
        if [ -n "$KEYCLOAK_ADMIN_USER" -a -n "$KEYCLOAK_ADMIN_PASSWORD" ]; then
            $JBOSS_HOME/bin/add-user-keycloak.sh -r master -u $KEYCLOAK_ADMIN_USER -p $KEYCLOAK_ADMIN_PASSWORD
        fi
        chown -R keycloak:keycloak $JBOSS_HOME/standalone
    fi

    if [ ! -f $JAVA_HOME/lib/security/cacerts.done ]; then
        touch $JAVA_HOME/lib/security/cacerts.done
        keytool -importkeystore \
            -srckeystore $JBOSS_HOME/standalone/configuration/$TRUSTSTORE -srcstorepass $TRUSTSTORE_PASSWORD \
            -destkeystore $JAVA_HOME/lib/security/cacerts -deststorepass changeit
    fi

    for c in $KEYCLOAK_WAIT_FOR; do
        echo -n "Waiting for $c ... "
        while ! nc -w 1 -z ${c/:/ }; do sleep 0.1; done
        echo "done"
    done
    set -- gosu keycloak "$@"
    echo "Starting Keycloak $KEYCLOAK_VERSION"
fi

exec "$@"
