FROM caliveapicreator/3.2

# Add the license
# ADD ./etc/license/CA_Technologies_LiveAPI_License.json /usr/local/tomcat/bin/EvalLicense_exp20171007.txt
ADD ./CA_Technologies_LiveAPI_License.json /usr/local/tomcat/bin/EvalLicense_exp20171007.txt

# Create the keystore folder
# CMD mkdir -p $CATALINA_HOME/conf/keystore

# Add the private keys (p12)
# ADD ./etc/tls/private/* $CATALINA_HOME/conf/keystore

# Add the public certificates
# ADD ./etc/tls/certs/* $CATALINA_HOME/conf/keystore

# Configuration a dedicated port for API Server and API Gateway to communicate
