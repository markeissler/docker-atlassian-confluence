#!/bin/bash

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
if [ "$(stat --format "%Y" "${CONF_INSTALL}/conf/server.xml")" -eq "0" ]; then
  if [ -n "${X_PROXY_NAME}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${CONF_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_PORT}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${CONF_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_SCHEME}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${CONF_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_SECURE}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "secure" --value "${X_PROXY_SECURE}" "${CONF_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PATH}" ]; then
    xmlstarlet ed --inplace --pf --ps --update '//Context[@docBase="../confluence"]/@path' --value "${X_PATH}" "${CONF_INSTALL}/conf/server.xml"
  fi
fi

if [ -f "${CERTIFICATE}" ] || [ -f "${CERTIFICATE}.p12" ]; then
  # convert PKCS12 certificate format to JKS certificate format
  #
  # To generate a pkcs12 file from an openssl self-signed cert and key file:
  #   > openssl pkcs12 -export -in server_cert.pem -inkey server_key.pem -out certificate.p12
  #       -passout pass:changeit -name "confluence"
  #
  # To test the insertion:
  #   > docker exec -it <CONTAINER_ID> /bin/bash
  #   > keytool -list -keystore $JAVA_HOME/jre/lib/security/cacerts -v | grep Alias | grep confluence
  #
  if [[ "${CERTIFICATE}" =~ .p12$ || -f "${CERTIFICATE}.p12" ]]; then
    keytool -noprompt -storepass changeit -importkeystore \
      -srckeystore ${CERTIFICATE%.p12}.p12 -srcstoretype PKCS12 -srcstorepass changeit -alias confluence \
      -destkeystore ${JAVA_CACERTS} -deststoretype JKS -deststorepass changeit -destalias confluence
  else
    keytool -noprompt -storepass changeit \
      -keystore ${JAVA_CACERTS} -import -file ${CERTIFICATE} -alias confluence
  fi

  # Update the server.xml file
  # <!--
  # <Connector port="8443" maxHttpHeaderSize="8192"
  #    maxThreads="150" minSpareThreads="25"
  #    protocol="org.apache.coyote.http11.Http11NioProtocol"
  #    enableLookups="false" disableUploadTimeout="true"
  #    acceptCount="100" scheme="https" secure="true"
  #    clientAuth="false" sslProtocol="TLSv1.2" sslEnabledProtocols="TLSv1.2" SSLEnabled="true"
  #    URIEncoding="UTF-8" keystorePass="<MY_CERTIFICATE_PASSWORD>"/>
  # -->
  xmlstarlet ed --inplace --pf --ps \
    --subnode "Server/Service" --type elem --name "ConnectorTMP" --value "" \
    --insert  "//ConnectorTMP" --type attr --name "port" --value "8443" \
    --insert  "//ConnectorTMP" --type attr --name "protocol" --value "org.apache.coyote.http11.Http11NioProtocol" \
    --insert  "//ConnectorTMP" --type attr --name "maxHttpHeaderSize" --value "8192" \
    --insert  "//ConnectorTMP" --type attr --name "SSLEnabled" --value "true"  \
    --insert  "//ConnectorTMP" --type attr --name "maxThreads" --value "150" \
    --insert  "//ConnectorTMP" --type attr --name "minSpareThreads" --value "25" \
    --insert  "//ConnectorTMP" --type attr --name "enableLookups" --value "false" \
    --insert  "//ConnectorTMP" --type attr --name "disableUploadTimeout" --value "true" \
    --insert  "//ConnectorTMP" --type attr --name "acceptCount" --value "100" \
    --insert  "//ConnectorTMP" --type attr --name "scheme" --value "https" \
    --insert  "//ConnectorTMP" --type attr --name "secure" --value "true" \
    --insert  "//ConnectorTMP" --type attr --name "clientAuth" --value "false" \
    --insert  "//ConnectorTMP" --type attr --name "sslProtocol" --value "TLSv1.2" \
    --insert  "//ConnectorTMP" --type attr --name "sslEnabledProtocols" --value "TLSv1.2" \
    --insert  "//ConnectorTMP" --type attr --name "useBodyEncodingForURI" --value "true" \
    --insert  "//ConnectorTMP" --type attr --name "keyAlias" --value "confluence" \
    --insert  "//ConnectorTMP" --type attr --name "keystoreFile" --value "${JAVA_CACERTS}" \
    --insert  "//ConnectorTMP" --type attr --name "keystorePass" --value "changeit" \
    --insert  "//ConnectorTMP" --type attr --name "keystoreType" --value "JKS" \
    --rename  "//ConnectorTMP" --value "Connector" \
    "${CONF_INSTALL}/conf/server.xml"

  # @TODO: Update Base URL to HTTPS
  #
  # https://confluence.atlassian.com/confkb/how-do-i-manually-change-the-base-url-310378877.html
  #

  # @TODO: Use xmlstarlet to update the web.xml file
  #
  # This will redirect all traffic to use HTTPS urls.
  #
  # Location: ${CONF_INSTALL}/confluence/WEB-INF/web.xml
  # <!--
  # <security-constraint>
  #   <web-resource-collection>
  #     <web-resource-name>Restricted URLs</web-resource-name>
  #     <url-pattern>/</url-pattern>
  #   </web-resource-collection>
  #   <user-data-constraint>
  #     <transport-guarantee>CONFIDENTIAL</transport-guarantee>
  #   </user-data-constraint>
  # </security-constraint>
  # -->
fi

exec "$@"
