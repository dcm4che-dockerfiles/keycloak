FROM java:8-jre

# explicitly set user/group IDs
RUN groupadd -r keycloak --gid=1029 && useradd -r -g keycloak --uid=1029 -d /opt/keycloak keycloak

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN arch="$(dpkg --print-architecture)" \
    && set -x \
    && apt-get update \
    && apt-get install -y netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch" \
    && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

ENV KEYCLOAK_VERSION=2.1.0.Final \
    JBOSS_HOME=/opt/keycloak \
    ADMIN_USER=admin \
    ADMIN_PASSWORD=admin \
    KEYCLOAK_ADMIN_USER=admin \
    KEYCLOAK_ADMIN_PASSWORD=admin

RUN cd $HOME \
    && curl -L https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz | tar xz \
    && mv $HOME/keycloak-$KEYCLOAK_VERSION $JBOSS_HOME \
    && $JBOSS_HOME/bin/add-user.sh $ADMIN_USER $ADMIN_PASSWORD --silent \
    && $JBOSS_HOME/bin/add-user-keycloak.sh -r master -u $KEYCLOAK_ADMIN_USER -p $KEYCLOAK_ADMIN_PASSWORD \
    && mkdir /docker-entrypoint.d  && mv $JBOSS_HOME/standalone/* /docker-entrypoint.d \
    && chown keycloak $JBOSS_HOME

# Default configuration: can be overridden at the docker command line
ENV JAVA_OPTS -Xms64m -Xmx512m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true
ENV KEYCLOAK_STANDALONE configuration
ENV KEYCLOAK_CHOWN $JBOSS_HOME/standalone

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

ENV PATH $JBOSS_HOME/bin:$PATH

VOLUME /opt/keycloak/standalone

# Expose the ports we're interested in
EXPOSE 8080 9990

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
