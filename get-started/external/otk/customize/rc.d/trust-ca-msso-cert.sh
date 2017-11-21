#!/usr/bin/env bash


# Check if the ca_msso private key already exists
keyExist=$(curl --insecure --cacert /tmp/localhost.pem --user admin:password https://localhost:8443/restman/1.0/restman/1.0/privateKeys?alias=ca_msso | grep "l7:Item")

# Create the private key if it doesn't exist.
if [[ ! -n "${keyExist}" ]]; then
    #### Begin private key install ####

    RESTMAN_PRIVATE_KEY_XML="/opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/ca_msso_key.xml"

    if cat "${RESTMAN_PRIVATE_KEY_XML}" | head -n 1 | grep PrivateKeyCreationContext; then
      echo "com.ca.trust-ca-msso-cert.sh : Call RESTMAN to create the private key"
      keyPostResult=$(curl --insecure \
                          --include \
                          --request POST \
                          --header "Content-Type: application/xml" \
                          --user 'admin:password' \
                          --cacert /tmp/localhost.pem \
                          --data @${RESTMAN_PRIVATE_KEY_XML} \
                          --url https://localhost:8443/restman/1.0/privateKeys/00000000000000000000000000000002:ca_msso)

    elif cat "${RESTMAN_PRIVATE_KEY_XML}" | head -n 1 | grep PrivateKeyImportContext; then
      echo "com.ca.trust-ca-msso-cert.sh : Call RESTMAN to import the private key"
      keyPostResult=$(curl --insecure \
                          --include \
                          --request POST \
                          --header "Content-Type: application/xml" \
                          --user 'admin:password' \
                          --cacert /tmp/localhost.pem \
                          --data @${RESTMAN_PRIVATE_KEY_XML} \
                          --url https://localhost:8443/restman/1.0/privateKeys/00000000000000000000000000000002:ca_msso/import)
    else
        echo "com.ca.trust-ca-msso-cert.sh : restman private key xml not recoca_msso private key created."
        exit 1
    fi

    case ${keyPostResult} in
    *"201 Created"* | *"200 OK"*)
        echo "com.ca.trust-ca-msso-cert.sh : ca_msso private key created."
        ;;
    *)
        echo "com.ca.trust-ca-msso-cert.sh : ERROR: Could not create ca_msso private key.\n"
        echo "com.ca.trust-ca-msso-cert.sh : Response was: \n${keyPostResult}\n"
        exit 1
        ;;
    esac
else
    echo "com.ca.trust-ca-msso-cert.sh : ca_msso private key already exists."
fi

echo "com.ca.trust-ca-msso-cert.sh : Set ca_msso as a certificate authority (CA)"
keyPostResult=$(curl --insecure \
                    --include \
                    --request PUT \
                    --header "Content-Type: application/xml" \
                    --user 'admin:password' \
                    --cacert /tmp/localhost.pem \
                    --data @${RESTMAN_PRIVATE_KEY_XML} \
                    --url 'https://localhost:8443/restman/1.0/privateKeys/00000000000000000000000000000002:ca_msso/specialPurpose?purpose=CA')

case ${keyPostResult} in
*"201 Created"* | *"200 OK"*)
    echo "com.ca.trust-ca-msso-cert.sh : ca_msso is now a certificate authority (CA)."
    ;;
*)
    echo "com.ca.trust-ca-msso-cert.sh : ERROR: Could not set ca_msso as a certificate authority (CA).\n"
    echo "com.ca.trust-ca-msso-cert.sh : Response was: \n${keyPostResult}\n"
    exit 1
    ;;
esac


# Check if Certificate already exists
certExist=$(curl --insecure --cacert /tmp/localhost.pem --user admin:password https://localhost:8443/restman/1.0/trustedCertificates?name=ca_msso | grep "l7:Item")

# Create the certificate if not exists
if [[ ! -n "$certExist" ]]; then
    #### Begin install certificate ######

    # Grab the private key
    certValue=$(curl -k -s -u admin:password https://localhost:8443/restman/1.0/privateKeys?alias=ca_msso | grep l7:Encoded | sed -e 's/.*<l7:Encoded>\(.*\)<\/l7:Encoded>/\1/')

    # Detemplatize the bundle file
    sed -i.bak "s|\\\$#{ENCODED_CERT}#|${certValue}|g" /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/ca_msso_cert.xml

    rm -f /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/ca_msso_cert.xml.bak

    # Call Restman to put the certificate.
    certPostResult=$(curl --insecure -i -X POST -H "Content-Type: application/xml"  --cacert /tmp/localhost.pem -d @/opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/ca_msso_cert.xml -u admin:password https://localhost:8443/restman/1.0/trustedCertificates)

    case ${certPostResult} in
    *"201 Created"*)
        echo "com.ca.trust-ca-msso-cert.sh : ca_msso certificate is now trusted."
        ;;
    *)
        echo "com.ca.trust-ca-msso-cert.sh : ERROR: Could not trust ca_msso certificate.\n"
        echo "com.ca.trust-ca-msso-cert.sh : Response was: \n${certPostResult}\n"
    esac

else
    echo "com.ca.trust-ca-msso-cert.sh : ca_msso certificate already trusted."
fi

# Check if FIP already exists
fipExist=$(curl --insecure --cacert /tmp/localhost.pem --user admin:password https://shewi04mac844.ca.com:8443/restman/1.0/identityProviders?name=CA_MSSO%20Identity%20Provider | grep "l7:Item")

# Create the FIP if not exists
if [[ ! -n "$fipExist" ]]; then
    #### Begin install FIP ######

    # Grab the certificate goid
    certIdValue=$(curl -k -s -u admin:password https://localhost:8443/restman/1.0/trustedCertificates?name=ca_msso | grep l7:Id | sed -e 's/.*<l7:Id>\(.*\)<\/l7:Id>/\1/')

    # Detemplatize the bundle file
    sed -i.bak "s|\\\$#{CA_MSSO_CERT_ID}#|${certIdValue}|g" /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/ca_msso_fip.xml

    rm -f /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/ca_msso_fip.xml.bak

    # Call Restman to put the FIP.
    fipPostResult=$(curl --insecure -i -X POST -H "Content-Type: application/xml"  --cacert /tmp/localhost.pem -d @/opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/ca_msso_fip.xml -u admin:password https://localhost:8443/restman/1.0/identityProviders)

    case ${fipPostResult} in
    *"201 Created"*)
        echo "com.ca.trust-ca-msso-cert.sh : CA_MSSO Identity Provider is now created."
        ;;
    *)
        echo "com.ca.trust-ca-msso-cert.sh : ERROR: Could not create CA_MSSO Identity Provider.\n"
        echo "com.ca.trust-ca-msso-cert.sh : Response was: \n${fipPostResult}\n"
    esac

else
    echo "com.ca.trust-ca-msso-cert.sh : CA_MSSO Identity Provider already existed."
fi
