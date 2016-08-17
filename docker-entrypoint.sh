#!/bin/bash

set -e

if [ "$1" = 'standalone.sh' ]; then
	set -- gosu keycloak "$@"
	echo "Starting Keycloak $KEYCLOAK_VERSION"
fi

exec "$@"
