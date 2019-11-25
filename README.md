# Keycloak Docker image

This docker image provides [Keycloak Authentication Server](https://www.keycloak.org/) initialized for securing the
DICOM Archive [dcm4chee-arc-light](https://github.com/dcm4che/dcm4chee-arc-light/wiki).

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

URL for accessing LDAP (optional, default is `ldap://ldap:389`).

#### `LDAP_BASE_DN`

Base domain name for LDAP (optional, default is `dc=dcm4che,dc=org`).

#### `LDAP_ROOTPASS`

Password to use to authenticate to LDAP (optional, default is `secret`).

#### `LDAP_ROOTPASS_FILE`

Password to use to authenticate to LDAP via file input (alternative to `LDAP_ROOTPASS`).

#### `LDAP_DISABLE_HOSTNAME_VERIFICATION`

Indicates to disable the verification of the hostname of the certificate of the LDAP server,
if using TLS (`LDAP_URL=ldaps://<host>:<port>`) (optional, default is `true`).

#### `KEYCLOAK_DEVICE_NAME`

Device name to lookup in LDAP for Audit Logging configuration (optional, default is `keycloak`).

#### `KEYCLOAK_USER`

By default there is no admin user created so you won't be able to login to the admin console of the Keycloak master
realm. To create an admin account you may use environment variables `KEYCLOAK_USER` and `KEYCLOAK_PASSWORD` to pass in
an initial username and password.

You can also create an account on an already running container by running:
```
$ docker exec <CONTAINER> add-user-keycloak.sh -u <USERNAME> -p <PASSWORD>
```

Then restarting the container:
```
$ docker restart <CONTAINER>
```

#### `KEYCLOAK_USER_FILE`

Keycloak admin user via file input (alternative to KEYCLOAK_USER).

#### `KEYCLOAK_PASSWORD`

User's password to use to authenticate to the Keycloak master realm.

#### `KEYCLOAK_PASSWORD_FILE`

User's password to use to authenticate to the Keycloak master realm via file input (alternative to KEYCLOAK_PASSWORD).

#### `KEYCLOAK_IMPORT`

Path to JSON file with ([previous exported](https://www.keycloak.org/docs/latest/server_admin/index.html#_export_import))
realm configuration to be imported on startup, if such realm does not already exists. Default is
`"/opt/keycloak/standalone/configuration/dcm4che-realm.json"`, provided by the docker image, customizable by
environment variables: 

##### `REALM_NAME`

Realm name (default is `dcm4che`). 

##### `SSL_REQUIRED`

Defining the SSL/HTTPS requirements for interacting with the realm:
- `none` - HTTPS is not required for any client IP address
- `external` - private IP addresses can access without HTTPS
- `all` - HTTPS is required for all IP addresses

(default is `external`).

##### `VALIDATE_PASSWORD_POLICY`

Indicates if Keycloak should validate the password with the realm password policy before updating it
(default value is `false`).

#### `HTTP_PORT`

HTTP port of Keycloak (optional, default is `8080`).

#### `HTTPS_PORT`

HTTPS port of Wildfly (optional, default is `8443`).

#### `MANAGEMENT_HTTP_PORT`

HTTP port of Wildfly Administration Console (optional, default is `9990`).

#### `MANAGEMENT_HTTPS_PORT`

HTTPS port of Wildfly Administration Console (optional, default is `9993`).

#### `WILDFLY_ADMIN_USER`

User to authenticate to the Wildfly Administration Console (optional, default is `admin`).

#### `SUPER_USER_ROLE`

User role to identify super users, which have unrestricted access to all UI functions of the Archive. Login/Logout of
such users will emit an [Audit Message for Security Alert](http://dicom.nema.org/medical/dicom/current/output/html/part15.html#sect_A.5.3.11)
with _Event Type Code_: `(110127,DCM,"Emergency Override Started")`/`(110138,DCM,"Emergency Override Stopped")`.
Optional, default is `admin`.

#### `KEYSTORE`

Path to keystore file with private key and certificate for HTTPS (default is
`/opt/keycloak/standalone/configuration/keystore/key.jks`, with sample key + certificate:
```
Subject    - CN=PACS_J4C,O=J4CARE,C=AT
Issuer     - CN=IHE Europe CA, O=IHE Europe, C=FR
Valid From - Sun Apr 02 06:38:46 UTC 2017
Valid To   - Fri Apr 02 06:38:46 UTC 2027
MD5 : 7a:b3:f7:5d:cf:6e:84:34:be:5a:7a:12:95:fa:46:76
SHA1 : a9:36:b3:b4:60:63:22:9e:f4:ae:41:d3:3b:97:ca:be:9b:a9:32:e9
```
provided by the docker image only for testing purpose).

#### `KEYSTORE_PASSWORD`

Password used to protect the integrity of the keystore specified by `KEYSTORE` (default is `secret`).

#### `KEYSTORE_PASSWORD_FILE`

Password used to protect the integrity of the keystore specified by `KEYSTORE` via file input
(alternative to `KEYSTORE_PASSWORD`).

#### `KEY_PASSWORD`

Password used to protect the private key in the keystore specified by `KEYSTORE`
(default is value of `KEYSTORE_PASSWORD`).

#### `KEY_PASSWORD_FILE`

Password used to protect the private key in the keystore specified by `KEYSTORE` via file input
(alternative to `KEY_PASSWORD`).

#### `KEYSTORE_TYPE`

Type (`JKS` or `PKCS12`) of the keystore specified by `KEYSTORE` (default is `JKS`).

#### `TRUSTSTORE`

Path to keystore file with trusted certificates for HTTPS (default is
`/opt/keycloak/standalone/configuration/keystore/cacerts.jks`, with sample CA certificate:
```
Subject    - CN=IHE Europe CA,O=IHE Europe,C=FR
Issuer     - CN=IHE Europe CA, O=IHE Europe, C=FR
Valid From - Fri Sep 28 11:19:29 UTC 2012
Valid To   - Wed Sep 28 11:19:29 UTC 2022
MD5 : 64:b6:1b:0f:8d:84:17:da:23:e4:e5:1c:56:ba:06:5d
SHA1 : 54:e0:10:c6:4a:fe:2c:aa:20:3f:50:95:45:82:cb:53:55:6b:07:7f
```
provided by the docker image only for testing purpose).

#### `TRUSTSTORE_PASSWORD`

Password used to protect the integrity of the keystore specified by `TRUSTSTORE` (optional, default is `secret`).

#### `TRUSTSTORE_PASSWORD_FILE`

Password used to protect the integrity of the keystore specified by `TRUSTSTORE` via file input
(alternative to `TRUSTSTORE_PASSWORD`).

#### `HOSTNAME_VERIFICATION_POLICY`

Specifies if Keycloak shall verify the hostname of the server’s certificate on outgoing HTTPS requests.
Accepted values are:
- `ANY` - the hostname is not verified.
- `WILDCARD` - allows wildcards in subdomain names i.e. `*.foo.com`.
- `STRICT` - CN must match hostname exactly.

Default value is `ANY`.

#### `JAVA_OPTS`

Java VM options (optional, default is `"-Xms64m -Xmx512m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true"`).

### [Logstash/GELF Logger](https://logging.paluch.biz/) configuration:

#### `LOGSTASH_HOST`

Hostname/IP-Address of the Logstash host. Required for emitting system logs to [Logstash](https://www.elastic.co/products/logstash).

#### `GELF_FACILITY`

Name of the Facility (optional, default is `keycloak`).

#### `GELF_LEVEL`

Log-Level threshold (optional, default is `WARN`).

#### `GELF_EXTRACT_STACK_TRACE`

Indicates if the Stack-Trace shall be sent in the StackTrace field (optional, default is `true`).

#### `GELF_FILTER_STACK_TRACE`

Indicates if Stack-Trace filtering shall be performed (optional, default is `true`).

### Keycloak Database configuration:

#### `DB_VENDOR`

DB vendor. Supported values are:
           
- `h2` - use embedded H2 database,
- `postgres` - use external PostgreSQL database,
- `mysql` - use external MySQL and MariaDB database,
- `oracle` - use external Oracle database.

(optional, default is `h2`).

#### `KEYCLOAK_DB_CONNECTION_URL`

JDBC driver connection URL. Not effective with embedded H2 database.
Optional, default depends on external database:

`DB_VENDOR` | default
-- | --
`postgres` | `jdbc:postgresql://db:5432/keycloak`
`mysql` | `jdbc:mysql://db:3306/keycloak?characterEncoding=UTF-8`
`oracle` | `jdbc:oracle:thin:@db:1521:keycloak`

#### `KEYCLOAK_DB_MAX_POOL_SIZE`

Maximum number of pooled DB connections (optional, default is `20`).

#### `KEYCLOAK_DB_USER`
             
User to authenticate to the external database (optional, default is `keycloak`).

#### `KEYCLOAK_DB_USER_FILE`
                  
User to authenticate to the external database via file input (alternative to `KEYCLOAK_DB_USER`).

#### `KEYCLOAK_DB_PASSWORD`

User's password to use to authenticate to the external database (optional, default is `keycloak`).

#### `KEYCLOAK_DB_PASSWORD_FILE`
                      
User's password to use to authenticate to the external database via file input (alternative to `DB_PASSWORD`).

### [Cluster TCPPING configuration](https://www.keycloak.org/2019/04/keycloak-cluster-setup.html):

Requires use of external Postgres or MySQL/MariaDB database to persist data.

#### `JGROUPS_TCP_PORT`

JGroups TCP stack port (optional, default is `7600`).

#### `JGROUPS_DISCOVERY_EXTERNAL_IP`

IP address of this host - must be accessible by the other Keycloak instances.

#### `JGROUPS_DISCOVERY_INITIAL_HOSTS`

IP address and port of all hosts (e.g.: `"172.21.48.4[7600],172.21.48.39[7600]"`)
