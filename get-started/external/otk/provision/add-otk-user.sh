#!/bin/sh
set -o errexit  # Exit if a command fails
set -o pipefail # Exit if one command in a pipeline fails
set -o nounset  # Treat  unset  variables and parameters as errors

# Script input
host="${1}"
user="${2}"
password="${3}"
identityprovider_name="${4}"
certificate_cn="${5}"
certificate_base64="${6}"

# Print message on error
error() {
    >&2 echo "Failed at line ${1}"
}
trap 'error ${LINENO}' ERR

# Check required commands
command -v curl
command -v grep
command -v cut
command -v sed

# HTTP client
# Arguments:
#   @url: http url to target
#   @credentials: user:password
#   @method: http method
#   @insecure: true or false
#   @data: data payload to send to the HTTP server
httpclient() {
  # Arguments
  local url="${1}"
  local credentials="${2}"
  local method="${3}"
  local insecure="${4}"
  local data="${5:-none}"

  # Variable
  local curl_opts=""

  # Begin
  if [ "${insecure}" == "true" ]; then
    curl_opts="${curl_opts} --insecure"
  fi

  if [ "${data}" != "none" ]; then
    curl ${curl_opts} --user "${user}:${password}" \
        --request "${method}" \
        --header 'Content-Type: application/xml' \
        --url "${url}" \
        --data "${data}"
  else
    curl ${curl_opts} --user "${user}:${password}" \
        --request "${method}" \
        --header 'Content-Type: application/xml' \
        --url "${url}"
  fi
}

# Return the ID of an Identity Provider
gw_identityprovider_id_get() {
    # Arguments
    local host="${1}"
    local user="${2}"
    local password="${3}"
    local identityprovider_name="${4// /%20}"

    # Begin
    httpclient "https://${host}/restman/1.0/identityProviders?name=${identityprovider_name}" \
               "${user}:${password}" "GET" "true" \
               | grep -w IdentityProvider \
               | grep -o -E "id=\"[0-9a-z]+\"" \
               | cut -d= -f 2 \
               | sed -e 's/^"//' -e 's/"$//'
}

# Create a user in an identity provider and returns its user id
gw_identityprovider_user_add() {
    # Arguments
    local host="${1}"
    local user="${2}"
    local password="${3}"
    local identityprovider_id="${4}"
    local user_to_add="${5}"

    # Contants
    local xml="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
    <l7:User providerId=\"${identityprovider_id}\" xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\">
      <l7:Login>${user_to_add}</l7:Login>
      <l7:Email>${user_to_add}@domain.local</l7:Email>
      <l7:SubjectDn>CN=${user_to_add}</l7:SubjectDn>
      <l7:Properties>
        <l7:Property key=\"name\">
          <l7:StringValue>${user_to_add}</l7:StringValue>
        </l7:Property>
      </l7:Properties>
    </l7:User>"

    # Begin
    httpclient "https://${host}/restman/1.0/identityProviders/${identityprovider_id}/users" \
               "${user}:${password}" "POST" "true" "${xml}" \
               | grep -E -o "<l7:Id>[a-x0-9]+" \
               | cut -d'>' -f 2
}

# Import a certificate into a user registered in an identity provider
gw_identityprovider_user_cert_import() {
    # Arguments
    local host="${1}"
    local user="${2}"
    local password="${3}"
    local identityprovider_id="${4}"
    local user_id="${5}"
    local user_certificate_base64="${6}"

    # Constants
    local xml="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
    <l7:CertificateData xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\">
    <l7:Encoded>${user_certificate_base64}</l7:Encoded>
    </l7:CertificateData>"

    # Begin
    httpclient "https://${host}/restman/1.0/identityProviders/${identityprovider_id}/users/${user_id}/certificate" \
               "${user}:${password}" "PUT" "true" "${xml}"
}

# Add a certificate to the truster certificates bucket of the gateway
gw_trustercertificate_add() {
    # Arguments
    local host="${1}"
    local user="${2}"
    local password="${3}"
    local user_to_register="${4}"
    local user_certificate_base64="${5}"

    # Constants
    local xml="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
    <l7:TrustedCertificate xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\">
      <l7:Name>${user_to_register}</l7:Name>
      <l7:CertificateData xmlns:l7=\"http://ns.l7tech.com/2010/04/gateway-management\">
        <l7:IssuerName>CN=${user_to_register}</l7:IssuerName>
        <l7:SubjectName>CN=${user_to_register}</l7:SubjectName>
        <l7:Encoded>${user_certificate_base64}</l7:Encoded>
      </l7:CertificateData>
      <l7:Properties>
        <l7:Property key=\"revocationCheckingEnabled\">
            <l7:BooleanValue>true</l7:BooleanValue>
        </l7:Property>
        <l7:Property key=\"trustAnchor\">
            <l7:BooleanValue>true</l7:BooleanValue>
        </l7:Property>
        <l7:Property key=\"trustedAsSamlAttestingEntity\">
            <l7:BooleanValue>false</l7:BooleanValue>
        </l7:Property>
        <l7:Property key=\"trustedAsSamlIssuer\">
            <l7:BooleanValue>false</l7:BooleanValue>
        </l7:Property>
        <l7:Property key=\"trustedForSigningClientCerts\">
            <l7:BooleanValue>false</l7:BooleanValue>
        </l7:Property>
        <l7:Property key=\"trustedForSigningServerCerts\">
            <l7:BooleanValue>false</l7:BooleanValue>
        </l7:Property>
        <l7:Property key=\"trustedForSsl\">
            <l7:BooleanValue>true</l7:BooleanValue>
        </l7:Property>
        <l7:Property key=\"verifyHostname\">
            <l7:BooleanValue>false</l7:BooleanValue>
        </l7:Property>
      </l7:Properties>
    </l7:TrustedCertificate>"

    # Begin
    httpclient "https://${host}/restman/1.0/trustedCertificates" \
               "${user}:${password}" "POST" "true" "${xml}"
}

identityprovider_id="$(gw_identityprovider_id_get "${host}" "${user}" "${password}" "${identityprovider_name}")"
user_id="$(gw_identityprovider_user_add "${host}" "${user}" "${password}" "${identityprovider_id}" "${certificate_cn}")"
gw_identityprovider_user_cert_import "${host}" "${user}" "${password}" "${identityprovider_id}" "${user_id}" "${certificate_base64}"
gw_trustercertificate_add "${host}" "${user}" "${password}" "${certificate_cn}" "${certificate_base64}"
>&2 echo "Done."
