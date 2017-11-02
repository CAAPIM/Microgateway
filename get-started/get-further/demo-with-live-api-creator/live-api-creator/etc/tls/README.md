#### Generate a new TLS configuration

##### Server:
- Create the private key
```
openssl genrsa -out server.key 2048
```
- Create the certificate Signing Request file (CSR)
```
openssl req -new -key server.key -out server.csr -subj "/C=CA/ST=British Columbia/L=Vancouver/O=CA Technologies/OU=APIM Gateway/CN=lacscale_node"
```

- Sign the certificate
```
openssl x509 -req -in server.csr -CA ../../../../../config/certs/rootCA.pem -CAkey ../../../../../config/certs/rootCA.key -CAcreateserial -out server.crt -days 500 -sha256
```

- Archive the private key and signed certificate into a P12
```
openssl pkcs12 -export -out server.p12 -inkey server.key -in server.crt
```
With:
  - `Enter Export Password:` = password

##### Clients:
- Create a Java KeyStore containing the CA Root certificate
```
keytool -importcert -file ../../../../../config/certs/rootCA.pem -keystore ca.jks
```
With:
  - `Enter keystore password:` = password
  - `Trust this certificate?` = yes
