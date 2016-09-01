#!/bin/bash

set -e

if [ "$1" = 'standalone.sh' ]; then
    if [ ! -d $JBOSS_HOME/standalone/configuration ]; then
        cp -r /docker-entrypoint.d/configuration $JBOSS_HOME/standalone
        $JBOSS_HOME/bin/add-user.sh $WILDFLY_ADMIN_USER $WILDFLY_ADMIN_PASSWORD --silent
        $JBOSS_HOME/bin/add-user-keycloak.sh -r master -u $KEYCLOAK_ADMIN_USER -p $KEYCLOAK_ADMIN_PASSWORD
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
