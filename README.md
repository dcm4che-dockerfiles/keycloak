### Keycloak Docker image

This is a Dockerfile for standalone Keycloak server which could be used for securing the DICOM Archive [dcm4chee-arc-light](https://github.com/dcm4che/dcm4chee-arc-light/wiki).

#### How to use this image

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

#### Environment Variables 

Below explained environment variables can be set as per one's application to override the default values if need be.
An example of how one can set an env variable in `docker run` command is shown below :

    -e KEYCLOAK_DEVICE_NAME=my-keycloak

_**Note**_ : If default values of any environment variables were overridden in startup of `slapd` container, 
then ensure that the same values are also used for overriding the defaults during startup of keycloak container. 

##### `LDAP_BASE_DN`

This environment variable sets the base domain name for LDAP. Default value is _**dc=dcm4che,dc=org**_.

##### `LDAP_ROOTPASS`

This environment variable sets the root password for LDAP. Default value is _**secret**_. 

##### `LDAP_CONFIGPASS`

This environment variable sets the password for users who wish to change the schema configuration in LDAP. 
Default value is _**secret**_. 

##### `KEYCLOAK_DEVICE_NAME`

This is the name of _**keycloak**_ device that is configured in LDAP. Default value is _**keycloak**_

##### `AUTH_SERVER_URL`

This environment variable is used to match auth-server-url used in the wildfly configuration for Keycloak. Default value is /auth.

##### `REALM_NAME`

This is the name of the realm configured in Keycloak for securing archive UI and RESTful services. Default value is _**dcm4che**_. 

#### Use Docker Compose

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
