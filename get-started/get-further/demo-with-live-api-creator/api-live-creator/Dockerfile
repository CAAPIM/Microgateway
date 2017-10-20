FROM caliveapicreator/4.0.00

# Add health check
HEALTHCHECK CMD curl --fail http://localhost:8080/rest/abl/admin/v2/@heartbeat || exit 1

# Add the license
ADD ./etc/license/CA_Technologies_LiveAPI_License.json /usr/local/tomcat/bin/EvalLicense_exp20171007.txt

# Add the server private and public key (p12)
ADD ./etc/tls/server.p12 $CATALINA_HOME/conf/server.p12

# Add the public certificates
ADD ./etc/tls/ca.jks $CATALINA_HOME/conf/ca.jks

# Customize the Tomcat configuration
ADD ./etc/tomcat/conf/* $CATALINA_HOME/conf/
