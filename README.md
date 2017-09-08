# Keycloak Docker image

This is a Dockerfile for standalone Keycloak server which could be used for securing the DICOM Archive [dcm4chee-arc-light](https://github.com/dcm4che/dcm4chee-arc-light/wiki).

## How to use this image

Before running the Keycloak container, you have to start a container providing the [LDAP server](https://github.com/dcm4che-dockerfiles/slapd-dcm4chee#how-to-use-this-image).

If you want to store Keycloak's System logs and User Authentication Audit Messages in [Elasticsearch](https://www.elastic.co/products/elasticsearch)
you have to also start containers providing [Elasticsearch, Logstash and Kibana](https://www.elastic.co/products):

```bash
> $docker run --name elasticsearch \
           -p 9200:9200 \
           -p 9300:9300 \
           -v /var/local/dcm4chee-arc/elasticsearch:/usr/share/elasticsearch/data \
           -d elasticsearch:5.2.2
```

```bash
> $docker run --name logstash \
           -p 12201:12201/udp \
           -p 8514:8514/udp \
           -p 8514:8514 \
           -v /var/local/dcm4chee-arc/elasticsearch:/usr/share/elasticsearch/data \
           --link elasticsearch:elasticsearch \
           -d dcm4che/logstash-dcm4chee:5.2.2-2
```

```bash
> $docker run --name kibana \
           -p 5601:5601 \
           --link elasticsearch:elasticsearch \
           -d kibana:5.2.2
```

You have to link the keycloak container with the _OpenLDAP_ (alias:`ldap`):

```bash
> $docker run --name keycloak \
           -p 8880:8880 \
           -p 8843:8843 \
           -p 8990:8990 \
           -v /var/local/dcm4chee-arc/keycloak:/opt/keycloak/standalone \
           --link slapd:ldap \
           -d dcm4che/keycloak:3.2.1-1
```

If you want to store Keycloak's System logs and Audit Messages in
[Elasticsearch](https://www.elastic.co/products/elasticsearch), you also have to link the keycloak container
with the _Logstash_ (alias:`logstash`) container:
```bash
> $docker run --name keycloak \
           -p 8880:8880 \
           -p 8843:8843 \
           -p 8990:8990 \
           -v /var/local/dcm4chee-arc/keycloak:/opt/keycloak/standalone \
           --link slapd:ldap \
           --link logstash:logstash \
           -d dcm4che/keycloak:3.2.1-1-logstash
```

## Environment Variables 

Below explained environment variables can be set as per one's application to override the default values if need be.
An example of how one can set an env variable in `docker run` command is shown below :

    -e KEYCLOAK_DEVICE_NAME=my-keycloak

_**Note**_ : If default values of any environment variables were overridden in startup of `slapd` container, 
then ensure that the same values are also used for overriding the defaults during startup of keycloak container. 

#### `LDAP_HOST`

This environment variable sets the host name for LDAP. Default value is `ldap`.

#### `LDAP_PORT`

This environment variable sets the port for LDAP. Default value is `389`.

#### `LDAP_BASE_DN`

This environment variable sets the base domain name for LDAP. Default value is `dc=dcm4che,dc=org`.

#### `LDAP_ROOTPASS`

This environment variable sets the root password for LDAP. Default value is `secret`. 

#### `LDAP_CONFIGPASS`

This environment variable sets the password for users who wish to change the schema configuration in LDAP. 
Default value is `secret`. 

#### `KEYCLOAK_DEVICE_NAME`

This is the name of `keycloak` device that is configured in LDAP. Default value is `keycloak`

#### `REALM_NAME`

This is the name of the realm configured in Keycloak for securing archive UI and RESTful services. Default value is `dcm4che`. 

#### `SSL_REQUIRED`

This environment variable defines the SSL/HTTPS requirements for interacting with the realm. Default value is `external`.

#### `HOSTNAME_VERIFICATION_POLICY`

This environment variable sets the verification policy for the hostname to be validated/authenticated. Default value set is `ANY`.
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

#### `KEYSTORE`

This environment variable sets the keystore used in ssl server identities in Wildfly configuration. Default value is `dcm4chee-arc/key.jks`.

#### `KEYSTORE_PASSWORD`

This environment variables sets the password of the keystore used in ssl server identities in Wildfly configuration. Default value is `secret`.

#### `KEY_PASSWORD`

This environment variables sets the password of the key used in ssl server identities in Wildfly configuration. Default value is `secret`.

#### `KEYSTORE_TYPE`

This environment variable sets the type of keystore that is used above. Default value is `JKS`.

#### `WILDFLY_ADMIN_USER`

This environment variable sets the admin user name for Wildfly. Default value is `admin`.

#### `WILDFLY_ADMIN_PASSWORD`

This environment variable sets the admin user name for Wildfly. Default value can be viewed in LDAP, it is set to `admin`.

#### `HTTP_PORT`

This environment variable sets the Http port of Wildfly. Default value is `8880`.

#### `HTTPS_PORT`

This environment variable sets the Https port of Wildfly. Default value is `8843`.

#### `MANAGEMENT_HTTP_PORT`

This environment variable sets the Management Http port of Wildfly. Default value is `8990`.


## Use Docker Compose

Alternatively you may use [Docker Compose](https://docs.docker.com/compose/) to take care for starting and linking
the containers, by specifying the services in a configuration file `docker-compose.yml` (e.g.):

````yaml
version: "2"
services:
  slapd:
    image: dcm4che/slapd-dcm4chee:2.4.44-10.5
    ports:
      - "389:389"
    env_file: docker-compose.env
    volumes:
      - /etc/timezone:/etc/timezone
      - /etc/localtime:/etc/localtime
      - /var/local/dcm4chee-arc/ldap:/var/lib/ldap
      - /var/local/dcm4chee-arc/slapd.d:/etc/ldap/slapd.d
  elasticsearch:
    image: elasticsearch:5.2.2
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - /etc/timezone:/etc/timezone
      - /etc/localtime:/etc/localtime
      - /var/local/dcm4chee-arc/elasticsearch:/usr/share/elasticsearch/data
  kibana:
    image: kibana:5.2.2
    ports:
      - "5601:5601"
    links:
      - elasticsearch:elasticsearch
    volumes:
      - /etc/timezone:/etc/timezone
      - /etc/localtime:/etc/localtime
  logstash:
    image: dcm4che/logstash-dcm4chee:5.2.2-2
    ports:
      - "12201:12201/udp"
      - "8514:8514/udp"
      - "8514:8514"
    links:
      - elasticsearch:elasticsearch
    volumes:
      - /etc/timezone:/etc/timezone
      - /etc/localtime:/etc/localtime
  keycloak:
    image: dcm4che/keycloak:3.2.1-1
    ports:
      - "8880:8880"
      - "8843:8843"
      - "8990:8990"
    env_file: docker-compose.env
    environment:
      HTTP_PORT: 8880
      HTTPS_PORT: 8843
      MANAGEMENT_HTTP_PORT: 8990
      KEYCLOAK_WAIT_FOR: ldap:389 logstash:8514
    links:
      - slapd:ldap
      - logstash:logstash
    volumes:
      - /etc/timezone:/etc/timezone
      - /etc/localtime:/etc/localtime
      - /var/local/dcm4chee-arc/keycloak:/opt/keycloak/standalone
````

and environment in the referenced file `docker-compose.env` (e.g.):

````INI
LDAP_BASE_DN=dc=dcm4che,dc=org
LDAP_ORGANISATION=dcm4che.org
LDAP_ROOTPASS=secret
LDAP_CONFIGPASS=secret
KEYCLOAK_DEVICE_NAME=keycloak
REALM_NAME=dcm4che
AUTH_SERVER_URL=https://gunter-nb:8843/auth
````

and starting them by
```bash
> $docker-compose up -d
````

#### Web Service URLs
- Keycloak Administration Console: <http://localhost:8880>, login with Username: `admin`, Password: `admin`.
- Kibana UI: <http://localhost:5601>
