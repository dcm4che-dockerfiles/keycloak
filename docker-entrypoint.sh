#!/bin/bash

set -e

if [ "$1" = 'standalone.sh' ]; then
	for f in $KEYCLOAK_STANDALONE; do
		if [ ! -d $JBOSS_HOME/standalone/$f ]; then
			echo "cp -r /docker-entrypoint.d/$f $JBOSS_HOME/standalone"
			cp -r /docker-entrypoint.d/$f $JBOSS_HOME/standalone
			chown -R keycloak:keycloak $JBOSS_HOME/standalone/$f
		fi
	done
	if [ ! -f $JBOSS_HOME/standalone/chown.done ]; then
		touch $JBOSS_HOME/standalone/chown.done
		for f in $KEYCLOAK_CHOWN; do
			echo "chown -R keycloak:keycloak $f"
			chown -R keycloak:keycloak $f
		done
	fi
	set -- gosu keycloak "$@"
	echo "Starting Keycloak $KEYCLOAK_VERSION"
fi

exec "$@"
