FROM openjdk:13-buster

# explicitly set user/group IDs
RUN groupadd -r keycloak --gid=1029 && useradd -r -g keycloak --uid=1029 -d /opt/keycloak keycloak

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.11
RUN arch="$(dpkg --print-architecture)" \
    && set -x \
    && apt-get update \
    && apt-get install -y netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch" \
    && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

ENV KEYCLOAK_VERSION=8.0.1 \
    LOGSTASH_GELF_VERSION=1.13.0 \
    DCM4CHE_VERSION=5.20.0 \
    JBOSS_HOME=/opt/keycloak

RUN cd $HOME \
    && curl -L https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz | tar xz \
    && mv keycloak-$KEYCLOAK_VERSION $JBOSS_HOME \
    && curl http://central.maven.org/maven2/biz/paluch/logging/logstash-gelf/$LOGSTASH_GELF_VERSION/logstash-gelf-$LOGSTASH_GELF_VERSION-logging-module.zip -O \
    && unzip logstash-gelf-$LOGSTASH_GELF_VERSION-logging-module.zip \
    && mv logstash-gelf-$LOGSTASH_GELF_VERSION/biz $JBOSS_HOME/modules/biz \
    && rmdir logstash-gelf-$LOGSTASH_GELF_VERSION \
    && rm logstash-gelf-$LOGSTASH_GELF_VERSION-logging-module.zip \
    && mkdir /docker-entrypoint.d \
    && mv $JBOSS_HOME/standalone/* /docker-entrypoint.d \
    && cd $JBOSS_HOME \
    && curl http://maven.dcm4che.org/org/dcm4che/dcm4che-jboss-modules/$DCM4CHE_VERSION/dcm4che-jboss-modules-${DCM4CHE_VERSION}.tar.gz | tar xz \
       modules/org/dcm4che/audit \
       modules/org/dcm4che/audit-keycloak \
       modules/org/dcm4che/conf/api \
       modules/org/dcm4che/conf/ldap \
       modules/org/dcm4che/conf/ldap-audit \
       modules/org/dcm4che/core \
       modules/org/dcm4che/net \
       modules/org/dcm4che/net-audit \
    && curl -f http://maven.dcm4che.org/org/dcm4che/jdbc-jboss-modules-psql/42.2.8/jdbc-jboss-modules-psql-42.2.8.tar.gz | tar xz \
    && curl -f http://maven.dcm4che.org/org/dcm4che/jdbc-jboss-modules-mysql/8.0.18/jdbc-jboss-modules-mysql-8.0.18.tar.gz | tar xz \
    && curl -f http://maven.dcm4che.org/org/dcm4che/jdbc-jboss-modules-oracle/12.2.0.1/jdbc-jboss-modules-oracle-12.2.0.1.tar.gz | tar xz \
    && chown -R keycloak:keycloak $JBOSS_HOME

COPY docker-entrypoint.sh setenv.sh /
COPY configuration /docker-entrypoint.d/configuration
COPY themes $JBOSS_HOME/themes

ENV LDAP_URL=ldap://ldap:389 \
    LDAP_BASE_DN=dc=dcm4che,dc=org \
    KEYSTORE=/opt/keycloak/standalone/configuration/keystores/key.jks \
    KEYSTORE_TYPE=JKS \
    TRUSTSTORE=/opt/keycloak/standalone/configuration/keystores/cacerts.jks \
    KEYCLOAK_IMPORT=/opt/keycloak/standalone/configuration/dcm4che-realm.json

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

ENV PATH $JBOSS_HOME/bin:$PATH

VOLUME /opt/keycloak/standalone

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["standalone.sh"]
