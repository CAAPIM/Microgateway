FROM caliveapicreator/4.0.00

# Add health check
HEALTHCHECK CMD curl --fail http://localhost:8080/rest/abl/admin/v2/@heartbeat || exit 1

# Install lacadmin (Live API Creator CLI)
RUN sh -c 'curl -sL https://deb.nodesource.com/setup_8.x | bash -' && \
    apt-get install -y nodejs && \
    npm install liveapicreator-admin-cli -g

# Add the license
# ENV LAC_DEFAULT_LICENSE_FILE /licenses/CA_Technologies_LiveAPI_License.json
# ADD ./etc/license/CA_Technologies_LiveAPI_License.json /licenses/CA_Technologies_LiveAPI_License.json

# Add the server private and public key (p12)
ADD ./etc/tls/node.p12 $CATALINA_HOME/conf/server.p12

# Add the public certificates
ADD ./etc/tls/ca.jks $CATALINA_HOME/conf/ca.jks

# Customize the Tomcat configuration
ADD ./etc/tomcat/conf/* $CATALINA_HOME/conf/
