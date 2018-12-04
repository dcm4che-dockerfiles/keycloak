# Keycloak Docker image

This is a Dockerfile for standalone Keycloak server which could be used for securing the DICOM Archive [dcm4chee-arc-light](https://github.com/dcm4che/dcm4chee-arc-light/wiki).

## Supported tags and respective `Dockerfile` links

- [`4.6.0-15.1` (*4.6.0-15.1/Dockerfile*)](https://github.com/dcm4che-dockerfiles/keycloak/blob/master/Dockerfile)
- [`4.6.0-15.1-logstash` (*4.6.0-15.1-logstash/Dockerfile*)](https://github.com/dcm4che-dockerfiles/keycloak/blob/logstash/Dockerfile)

## How to use this image

See [Running on Docker](https://github.com/dcm4che/dcm4chee-arc-light/wiki/Running-on-Docker) at the
[dcm4che Archive 5 Wiki](https://github.com/dcm4che/dcm4chee-arc-light/wiki).

## Environment Variables 

Below explained environment variables can be set as per one's application to override the default values if need be.
An example of how one can set an env variable in `docker run` command is shown below :

    -e KEYCLOAK_DEVICE_NAME=my-keycloak

_**Note**_ : If default values of any environment variables were overridden in startup of `slapd` container, 
then ensure that the same values are also used for overriding the defaults during startup of keycloak container. 

#### `LDAP_URL`

This environment variable sets the URL for accessing LDAP. Default value is `ldap://ldap:389`.

#### `LDAP_BASE_DN`

This environment variable sets the base domain name for LDAP. Default value is `dc=dcm4che,dc=org`.

#### `LDAP_ROOTPASS`

This environment variable sets the password for LDAP.
Only effective if the file specified by `LDAP_ROOTPASS_FILE` does not exist. Default value is `secret`.

#### `LDAP_ROOTPASS_FILE`

Path to file containing the password for LDAP.
If the file does not exist, it will be created containing the password specified by `LDAP_ROOTPASS`. 
Default value is `/tmp/ldap_rootpass`.

#### `KEYCLOAK_DEVICE_NAME`

This is the name of `keycloak` device that is configured in LDAP. Default value is `keycloak`

#### `HTTP_PORT`

This environment variable sets the Http port of Wildfly. Default value is `8080`.

#### `HTTPS_PORT`

This environment variable sets the Https port of Wildfly. Default value is `8443`.

#### `MANAGEMENT_HTTP_PORT`

This environment variable sets the Management Http port of Wildfly. Default value is `9990`.

#### `WILDFLY_ADMIN_USER`

This environment variable sets the admin user name for Wildfly. Default value is `admin`.

#### `KEYCLOAK_ADMIN_USER`

This environment variable sets the admin user name for Keycloak master realm. If not specified, no admin user 
for the Keycloak master realm will be created.

#### `KEYCLOAK_ADMIN_PASSWORD`

This environment variable sets the password for the `KEYCLOAK_ADMIN_USER`.
Only effective if `KEYCLOAK_ADMIN_USER` is set and the file specified by `KEYCLOAK_ADMIN_PASSWORD_FILE` does not exist.

#### `KEYCLOAK_ADMIN_PASSWORD_FILE`

Path to file containing the password for the `KEYCLOAK_ADMIN_USER`. Only effective if `KEYCLOAK_ADMIN_USER` is set.
If the file does not exist and if `KEYCLOAK_ADMIN_PASSWORD` is set, it will be created containing the password
specified by `KEYSTORE_PASSWORD`.
Default value is `/tmp/keycloak_admin_password`.

#### `SUPER_USER_ROLE`

This environment variable sets the user role to identify super users, which have unrestricted access to all UI functions
of the Archive, bypassing the verification of user permissions. Login/Logout of such users will emit an [Audit Message
for Security Alert](http://dicom.nema.org/medical/dicom/current/output/html/part15.html#sect_A.5.3.11) with EventTypeCode
`(110127,DCM,"Emergency Override Started")`/`(110138,DCM,"Emergency Override Stopped")`. Default value is `admin`.

#### `KEYSTORE`

This environment variable sets the keystore used in ssl server identities in Wildfly configuration. Default value is
`/opt/keycloak/standalone/configuration/keycloak/key.jks`.

#### `KEYSTORE_PASSWORD`

This environment variables sets the password of the keystore used in ssl server identities in Wildfly configuration.
Only effective if the file specified by `KEYSTORE_PASSWORD_FILE` does not exist. Default value is `secret`.

#### `KEYSTORE_PASSWORD_FILE`

Path to file containing the password of the keystore used in ssl server identities in Wildfly configuration.
If the file does not exist, it will be created containing the password specified by `KEYSTORE_PASSWORD`. 
Default value is `/tmp/keystore_password`.

#### `KEY_PASSWORD`

This environment variables sets the password of the key used in ssl server identities in Wildfly configuration.
Only effective if the file specified by `KEY_PASSWORD_FILE` does not exist. Default value is `secret`.

#### `KEY_PASSWORD_FILE`

Path to file containing the password of the key used in ssl server identities in Wildfly configuration.
If the file does not exist, it will be created containing the password specified by `KEY_PASSWORD`. 
Default value is `/tmp/key_password`.

#### `KEYSTORE_TYPE`

This environment variable sets the type of keystore that is used above. Default value is `JKS`.

#### `TRUSTSTORE`

This environment variable sets the truststore which will be used to verify archive's certificate and/or keycloak-proxy's certificate 
in Https communication. Default value is `/opt/keycloak/standalone/configuration/keycloak/cacerts.jks`.

#### `TRUSTSTORE_PASSWORD`

This environment variable sets the password of the above truststore.
Only effective if the file specified by `TRUSTSTORE_PASSWORD_FILE` does not exist. Default value is `secret`.

#### `TRUSTSTORE_PASSWORD_FILE`

Path to file containing the password of the above truststore.
If the file does not exist, it will be created containing the password specified by `TRUSTSTORE_PASSWORD`. 
Default value is `/tmp/truststore_password`.

#### `SSL_REQUIRED`

This environment variable defines the SSL/HTTPS requirements for interacting with the realm. Default value is `external`.
Values which are accepted are : `external`, `none` or `all`.

#### `VALIDATE_PASSWORD_POLICY`

Indicates if Keycloak should validate the password with the realm password policy before updating it. Default value is `false`.

#### `REALM_NAME`

This is the name of the realm configured in Keycloak for securing archive UI and RESTful services. Default value is `dcm4che`. 

#### `HOSTNAME_VERIFICATION_POLICY`

This environment variable sets the verification policy for the hostname to be validated/authenticated. Default value is `ANY`.
Values which are accepted are : `ANY`, `WILDCARD` or `STRICT`.

#### `SYSLOG_HOST`

This environment variable is the host name of logstash container used in wildfly configuration. Default value is `logstash`.

#### `GELF_FACILITY`

This environment variable sets the facility name needed by GELF logging used in wildfly configuration. Default value is `dcm4chee-arc`.

#### `GELF_LEVEL`

This environment variable sets the level of GELF logging used in wildfly configuration. Default value is `WARN`.

#### `JAVA_OPTS`

This environment variable is used to set the JAVA_OPTS during archive startup. Default value is 
`"-Xms64m -Xmx512m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true"`