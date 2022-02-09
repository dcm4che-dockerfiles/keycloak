#!/bin/bash

set -e

if [ "$1" = 'standalone.sh' ]; then

    . setenv.sh

	  chown -c keycloak:keycloak $JBOSS_HOME/standalone
	  for d in $WILDFLY_STANDALONE_PURGE; do
		    rm -rfv $JBOSS_HOME/standalone/$d/*
	  done
		cp -rupv /docker-entrypoint.d/configuration $JBOSS_HOME/standalone
		cp -rupv /docker-entrypoint.d/deployments $JBOSS_HOME/standalone
    cp -rupv /docker-entrypoint.d/themes $JBOSS_HOME
		if head -n2 $JBOSS_HOME/standalone/configuration/dcm4che-realm.json | grep -q '\${env.REALM_NAME}'; then
        sed -e "s%\${env.REALM_NAME}%${REALM_NAME:-dcm4che}%" \
            -e "s%\${env.LDAP_BASE_DN}%${LDAP_BASE_DN}%" \
            -e "s%\${env.LDAP_URL}%${LDAP_URL}%" \
            -e "s%\${env.LDAP_ROOTPASS}%${LDAP_ROOTPASS}%" \
            -e "s%\${env.SSL_REQUIRED}%${SSL_REQUIRED:-external}%" \
            -e "s%\${env.VALIDATE_PASSWORD_POLICY}%${VALIDATE_PASSWORD_POLICY:-false}%" \
            -i $JBOSS_HOME/standalone/configuration/dcm4che-realm.json
		fi
    if [ -n "$KEYCLOAK_USER" -a -n "$KEYCLOAK_PASSWORD" -a ! -f $JBOSS_HOME/standalone/configuration/add-user-keycloak.done ]; then
        touch $JBOSS_HOME/standalone/configuration/add-user-keycloak.done
        $JBOSS_HOME/bin/add-user-keycloak.sh -u $KEYCLOAK_USER -p $KEYCLOAK_PASSWORD
    fi

    if [ ! -f $JAVA_HOME/lib/security/cacerts.done ]; then
        touch $JAVA_HOME/lib/security/cacerts.done
        if [ "$EXTRA_CACERTS" ]; then
            keytool -importkeystore \
                -srckeystore $EXTRA_CACERTS -srcstorepass $EXTRA_CACERTS_PASSWORD \
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
