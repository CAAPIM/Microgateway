#!/usr/bin/env bash

echo "add-ingress-gateway-user.sh : Call RESTMAN to add an ingress gateway user to the OTK identity provider"

while [ "$(curl --insecure \
                --user 'admin:password' \
                --url 'https://localhost:8443/restman/1.0/identityProviders' \
                \
                | grep -A 1 '<l7:Name>Gateway as a Client Identity Provider</l7:Name>' \
                | grep '<l7:Id>' \
                | grep -o -E '[a-z0-9]{4,}')" != "ada77b26afbc26b56accc9c84c0e3dfd" ]; do

        echo "add-ingress-gateway-user.sh : Waiting for the OTK Identity Provider"
        sleep 5
done

RESTMAN_BUNDLE_PATH="/opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/add_ingress_gateway_user.bundle"

if curl --insecure \
        --request PUT \
        --header "Content-Type: application/xml" --data @${RESTMAN_BUNDLE_PATH} \
        --user 'admin:password' \
        --url https://localhost:8443/restman/1.0/bundle; then

  echo "add-ingress-gateway-user.sh : done"
else
  echo "add-ingress-gateway-user.sh : failed"
fi
