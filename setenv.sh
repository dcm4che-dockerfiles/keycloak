#!/bin/bash

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

case $DB_VENDOR in
	postgres)
		DB="-psql"
		;;
	mysql)
		DB="-mysql"
		;;
	oracle)
		DB="-oracle"
		;;
esac

if [ -n "$DB" -a -n "$JGROUPS_DISCOVERY_EXTERNAL_IP" -a -n "$JGROUPS_DISCOVERY_INITIAL_HOSTS" ]; then
	HA="-ha"
fi

if [ -n "$LOGSTASH_HOST" ]; then
	LOGSTASH="-logstash"
fi

BIND_IP=$(hostname -i)
SYS_PROPS="-c keycloak${HA}${DB}${LOGSTASH}.xml"
SYS_PROPS+=" -Djboss.bind.address=$BIND_IP"
SYS_PROPS+=" -Djboss.bind.address.management=$BIND_IP"
SYS_PROPS+=" -Djboss.bind.address.private=$BIND_IP"
SYS_PROPS+=" -Djboss.management.http.port=${MANAGEMENT_HTTP_PORT:-9990}"
SYS_PROPS+=" -Djboss.management.https.port=${MANAGEMENT_HTTPS_PORT:-9993}"
SYS_PROPS+=" -Djboss.http.port=${HTTP_PORT:-8080}"
SYS_PROPS+=" -Djboss.https.port=${HTTPS_PORT:-8443}"
SYS_PROPS+=" -Djboss.jgroups.tcp.port=${JGROUPS_TCP_PORT:-7600}"
SYS_PROPS+=" -Dkeycloak.import=$KEYCLOAK_IMPORT"
