#!/bin/bash

set -e

if [ "$1" = 'standalone.sh' ]; then
    if [ ! -d $JBOSS_HOME/standalone/configuration ]; then
        cp -r /docker-entrypoint.d/deployments $JBOSS_HOME/standalone
        cp -r /docker-entrypoint.d/configuration $JBOSS_HOME/standalone
        sed -e "s%\${env.KEYCLOAK_REALM}%${KEYCLOAK_REALM}%" \
            -e "s%\${env.LDAP_BASE_DN}%${LDAP_BASE_DN}%" \
            -e "s%\${env.LDAP_HOST}%${LDAP_HOST}%" \
            -e "s%\${env.LDAP_PORT}%${LDAP_PORT}%" \
            -e "s%\${env.LDAP_ROOTPASS}%${LDAP_ROOTPASS}%" \
            -e "s%\${env.KEYCLOAK_SSL_REQUIRED}%${KEYCLOAK_SSL_REQUIRED}%" \
            -i $JBOSS_HOME/standalone/configuration/dcm4che-realm.json
        if [ -n "$WILDFLY_ADMIN_USER" -a -n "$WILDFLY_ADMIN_PASSWORD" ]; then
            $JBOSS_HOME/bin/add-user.sh $WILDFLY_ADMIN_USER $WILDFLY_ADMIN_PASSWORD --silent
        fi
        if [ -n "$KEYCLOAK_ADMIN_USER" -a -n "$KEYCLOAK_ADMIN_PASSWORD" ]; then
            $JBOSS_HOME/bin/add-user-keycloak.sh -r master -u $KEYCLOAK_ADMIN_USER -p $KEYCLOAK_ADMIN_PASSWORD
        fi
        chown -R keycloak:keycloak $JBOSS_HOME/standalone
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
