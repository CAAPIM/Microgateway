#!/usr/bin/env bash

echo "add-edge-gateway-user.sh : Call RESTMAN to add an edge gateway user to the OTK identity provider"

while [ "$(curl --insecure \
                --user 'admin:password' \
                --url 'https://localhost:8443/restman/1.0/identityProviders' \
                \
                | grep -A 1 '<l7:Name>Gateway as a Client Identity Provider</l7:Name>' \
                | grep '<l7:Id>' \
                | grep -o -E '[a-z0-9]{4,}')" != "ada77b26afbc26b56accc9c84c0e3dfd" ]; do

        echo "add-edge-gateway-user.sh : Waiting for the OTK Identity Provider"
        sleep 5
done

RESTMAN_BUNDLE_PATH="/opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/add_edge_gateway_user.bundle
                     /opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/add_microgateway_user.bundle"

for bundle in ${RESTMAN_BUNDLE_PATH}; do
  if curl --insecure \
          --request PUT \
          --header "Content-Type: application/xml" --data @${bundle} \
          --user 'admin:password' \
          --url https://localhost:8443/restman/1.0/bundle; then

    echo "add-edge-gateway-user.sh : ${bundle} added"
  else
    echo "add-edge-gateway-user.sh : ${bundle} failed to load"
  fi
done
