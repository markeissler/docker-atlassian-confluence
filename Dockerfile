FROM openjdk:8
MAINTAINER Mark Eissler

# Setup useful environment variables
ENV CONF_HOME     /var/atlassian/confluence
ENV CONF_RUNTIME  /var/atlassian/confluence_runtime
ENV CONF_INSTALL  /opt/atlassian/confluence
ENV CONF_VERSION  6.3.1

ENV JAVA_CACERTS  $JAVA_HOME/jre/lib/security/cacerts
ENV CERTIFICATE   $CONF_HOME/certificate

# Install Atlassian Confluence and helper tools and setup initial home
# directory structure.
#
# Standard port and secure ports reconfigured to 8080 and 8443.
#
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends xmlstarlet \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 \
    && apt-get clean \
    && mkdir -p                "${CONF_HOME}" \
    && mkdir -p                "${CONF_HOME}/index" \
    && chmod -R 700            "${CONF_HOME}" \
    && chown daemon:daemon     "${CONF_HOME}" \
    && mkdir -p                "${CONF_INSTALL}/conf" \
    && curl -Ls                "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.42.tar.gz" | tar -xz --directory "${CONF_INSTALL}/confluence/WEB-INF/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar" \
    && chmod -R 700            "${CONF_INSTALL}/conf" \
    && chmod -R 700            "${CONF_INSTALL}/temp" \
    && chmod -R 700            "${CONF_INSTALL}/logs" \
    && chmod -R 700            "${CONF_INSTALL}/work" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/conf" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/temp" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/logs" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/work" \
    && echo -e                 "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
    && xmlstarlet              ed --inplace \
        --delete               "Server/@debug" \
        --delete               "Server/Service/Connector/@debug" \
        --delete               "Server/Service/Connector/@useURIValidationHack" \
        --delete               "Server/Service/Connector/@minProcessors" \
        --delete               "Server/Service/Connector/@maxProcessors" \
        --delete               "Server/Service/Engine/@debug" \
        --delete               "Server/Service/Engine/Host/@debug" \
        --delete               "Server/Service/Engine/Host/Context/@debug" \
                               "${CONF_INSTALL}/conf/server.xml" \
    && xmlstarlet              ed --inplace --pf --ps \
        --update               "Server/Service/Connector/@port" --value "8080" \
        --update               "Server/Service/Connector/@redirectPort" --value "8443" \
                               "${CONF_INSTALL}/conf/server.xml" \
    && touch -d "@0"           "${CONF_INSTALL}/conf/server.xml" \
    && chown daemon:daemon     "${JAVA_CACERTS}"

# Support Swarm and NFS by moving caches to local (ephemeral) storage.
#
#   CONF_HOME/index
#       - content index, we move all indexes to CONF_RUNTIME for better performance
#
#   CONF_HOME/plugins-osgi-cache/felix/felix-cache
#       - felix plugin cache, we want to move just felix-cache but Confluence will overwrite
#       a symlink on felix-cache so we move all felix to CONF_RUNTIME
#
RUN set -x \
    && rm -rf                  "${CONF_HOME}/index" \
    && mkdir -p                "${CONF_HOME}/plugins-osgi-cache" \
    && chmod -R 700            "${CONF_HOME}" \
    && chown -R daemon:daemon  "${CONF_HOME}" \
    && mkdir -p                "${CONF_RUNTIME}/index" \
    && mkdir -p                "${CONF_RUNTIME}/plugins-osgi-cache/felix" \
    && chmod -R 700            "${CONF_RUNTIME}" \
    && chown -R daemon:daemon  "${CONF_RUNTIME}" \
    && ln -s                   "${CONF_RUNTIME}/index" "${CONF_HOME}/index" \
    && ln -s                   "${CONF_RUNTIME}/plugins-osgi-cache/felix" "${CONF_HOME}/plugins-osgi-cache/felix"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8080
EXPOSE 8443

# Persist the following directories
#
#   /var/atlassian/confluence - confluence.home (settings)
#   /opt/atlassian/confluence/logs - server logs
#
VOLUME ["/var/atlassian/confluence", "/opt/atlassian/confluence/logs"]

# Set the default working directory as the Confluence home directory.
WORKDIR /var/atlassian/confluence

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian Confluence as a foreground process by default.
CMD ["/opt/atlassian/confluence/bin/catalina.sh", "run"]
