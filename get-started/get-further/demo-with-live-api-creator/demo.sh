#!/bin/bash
set -o errexit  # Exit if a command fails
set -o pipefail # Exit if one command in a pipeline fails
set -o nounset  # Treat  unset  variables and parameters as errors

trap 'log::error ${LINENO}' ERR

CWD="$(cd "$(dirname "$0")" && pwd)" # Script directory

# Load the configuration
# shellcheck source=./config.sh
source "${CWD}/config.sh"

# Debug mode
[ "${DEMO_DEBUG:-0}" -eq 1 ] && set -o xtrace

# COLORS
COLOR_GREEN="\033[0;32m"   # green
COLOR_RED="\033[0;31m"     # red
COLOR_DEFAULT="\033[0;39m" # default terminal color

# Main function
function main() {
    local action="${1:-}"

    case "$action" in
        "start")
            log::info "Checking required commands"
            check::required_cli
            if [ "$CHECK_VERSION" == "true" ]; then
              check::required_version "docker-compose" \
                                      "$(docker-compose --version | grep -E -o "[0-9.]+\.[0-9]+")" \
                                      "$DOCKER_COMPOSE_MIN_VERSION"
            fi

            log::info "Checking accepted licenses"
            if [ "$ACCEPT_LICENSE" == "true" ]; then
              license::set "${MICROGATEWAY_PATH}/config/license-agreement.env" "ACCEPT_LICENSE=true"
              license::set "${INGRESS_GATEWAY_PATH}/config/license-agreement.env" "ACCEPT_LICENSE=true"
              license::set "${OTK_PATH}/config/license.env" "ACCEPT_LICENSE=true"
              license::set "${API_LIVE_CREATOR_PATH}/etc/eula.env" "ca_accept_license=ENU"
            else
              log::error "Expecting ACCEPT_LICENSE=\"true\" but found ACCEPT_LICENSE=\"$ACCEPT_LICENSE\""
            fi

            log::info "Deploying the database of the microservice Orders"
            microservice::deploy "${MICROSERVICE_BASE_PATH}/orders" "$DOCKER_PROJECT_NAME"

            log::info "Deploying the database of the microservice Recommendation"
            microservice::deploy "${MICROSERVICE_BASE_PATH}/recommendation" "$DOCKER_PROJECT_NAME"

            if [ "$MQTT_SCALE" -gt 0 ]; then
              log::info "Deploying MQTT server"
              log::info "A machine-to-machine (M2M)/\"Internet of Things\" connectivity protocol"
              mqtt::deploy "$MQTT_PATH" "$DOCKER_PROJECT_NAME" "$MQTT_SCALE"
            fi

            log::info "Deploying CA OTK"
            otk::deploy "$OTK_PATH" "$DOCKER_PROJECT_NAME"

            log::info "Deploying CA Microgateway"
            microgateway::deploy "$MICROGATEWAY_PATH" \
                                 "$MICROGATEWAY_PATH_ADDONS" \
                                 "$DOCKER_PROJECT_NAME" \
                                 "$MICROGATEWAY_SSG_SCALE" \
                                 "$MICROGATEWAY_DB_TYPE" \
                                 "$MICROGATEWAY_PATH_CUSTOMIZATION"

            log::info "Deploying Ingress Gateway"
            ingress_gateway::deploy "$INGRESS_GATEWAY_PATH" \
                                    "$DOCKER_PROJECT_NAME" \
                                    "$INGRESS_GATEWAY_DB_TYPE"

            log::info "Bootstrapping CA Live API Creator"
            api_live_creator::deploy "${API_LIVE_CREATOR_PATH}" "$DOCKER_PROJECT_NAME" "0"

            log::info "Waiting for CA Live API Creator"
            api_live_creator::wait  "$API_LIVE_CREATOR_RETRY_TIMEOUT" \
                                    "$API_LIVE_CREATOR_HOST" \
                                    "$API_LIVE_CREATOR_USER" \
                                    "$API_LIVE_CREATOR_PASSWORD"

            log::info "Scaling CA Live API Creator to $API_LIVE_CREATOR_NODES node(s)"
            api_live_creator::deploy "${API_LIVE_CREATOR_PATH}" "$DOCKER_PROJECT_NAME" "$API_LIVE_CREATOR_NODES"

            log::info "Logging in to CA Live API Creator"
            api_live_creator::login "$API_LIVE_CREATOR_HOST" \
                                    "$API_LIVE_CREATOR_USER" \
                                    "$API_LIVE_CREATOR_PASSWORD" \
                                    "$API_LIVE_CREATOR_SERVER_ALIAS"

            log::info "Creating the microservice Orders with CA Live API Creator"
            api_live_creator::create_api "${MICROSERVICE_BASE_PATH}/orders/customer_orders.json" \
                                         "orders" \
                                         "root"

            log::info "Creating the microservice Recommendation with CA Live API Creator"
            api_live_creator::create_api "${MICROSERVICE_BASE_PATH}/recommendation/recommendation.json" \
                                         "rec" \
                                         "root"

            log::info "Waiting for all containers to be healthy"
            log::info "If timeout, you can wait manually with the command:"
            log::info "docker ps --format \"table {{.Names}}\\t{{.Status}}\""
            docker::wait_all_healthy "$START_TIMEOUT"

            log::info "Checking that the demo is up"
            docker::check_project_up "$DOCKER_PROJECT_NAME"

            log::info "Enabling mTLS on gateways"
            microgateway::beta::enable_mtls "ssg" "$DOCKER_PROJECT_NAME" "$MICROGATEWAY_PATH" "$MICROGATEWAY_USERNAME" "$MICROGATEWAY_PASSWORD" "policy" "RouteHttp"
            microgateway::beta::enable_mtls "ssg" "$DOCKER_PROJECT_NAME" "$MICROGATEWAY_PATH" "$MICROGATEWAY_USERNAME" "$MICROGATEWAY_PASSWORD" "policy" "RouteOrchestrator"
            microgateway::beta::enable_mtls "edge-ssg" "$DOCKER_PROJECT_NAME" "$INGRESS_GATEWAY_PATH" "$INGRESS_GATEWAY_USERNAME" "$INGRESS_GATEWAY_PASSWORD" "policy" "RouteHttp"
            microgateway::beta::enable_mtls "edge-ssg" "$DOCKER_PROJECT_NAME" "$INGRESS_GATEWAY_PATH" "$INGRESS_GATEWAY_USERNAME" "$INGRESS_GATEWAY_PASSWORD" "policy" "RouteOrchestrator"
            microgateway::beta::enable_mtls "edge-ssg" "$DOCKER_PROJECT_NAME" "$INGRESS_GATEWAY_PATH" "$INGRESS_GATEWAY_USERNAME" "$INGRESS_GATEWAY_PASSWORD" "policy" "custom_RouteOrchestrator"

            >&2 echo
            log::info "done"
            ;;

        "stop")
            log::info "Checking required commands"
            check::required_cli

            log::info "Destroying CA Live API Creator"
            api_live_creator::destroy "${API_LIVE_CREATOR_PATH}" "$DOCKER_PROJECT_NAME"
            log::info "Destroying the database of the microservice Orders"
            microservice::destroy "${MICROSERVICE_BASE_PATH}/orders" "$DOCKER_PROJECT_NAME"
            log::info "Destroying the database of the microservice Recommendation"
            microservice::destroy "${MICROSERVICE_BASE_PATH}/recommendation" "$DOCKER_PROJECT_NAME"

            log::info "Destroying CA Microgateway"
            microgateway::destroy "$MICROGATEWAY_PATH" \
                                  "$MICROGATEWAY_PATH_ADDONS" \
                                  "$DOCKER_PROJECT_NAME" \
                                  "$MICROGATEWAY_DB_TYPE"

            log::info "Destroying Ingress Gateway"
            ingress_gateway::destroy "$INGRESS_GATEWAY_PATH" \
                                     "$DOCKER_PROJECT_NAME" \
                                     "$INGRESS_GATEWAY_DB_TYPE"

            log::info "Destroying CA OTK"
            otk::destroy "$OTK_PATH" "$DOCKER_PROJECT_NAME"

            if [ "$MQTT_SCALE" -gt 0 ]; then
              log::info "Destroying MQTT"
              mqtt::destroy "$MQTT_PATH" "$DOCKER_PROJECT_NAME"
            fi

            log::info "Removing the Docker network ${DOCKER_PROJECT_NAME}_default"
            docker::network::rm "${DOCKER_PROJECT_NAME}_default"

            >&2 echo
            log::info "done"
            ;;

          "help") usage ;;

          *) log::error "Unknown action \"$action\", see help \"$0 help\"." ;;
    esac
}

# Help function
function usage() {
  >&2 echo "
  Start and stop the demo of the Microgateway and CA Live API Creator

  $0 start|stop
  "
}

# Logging functions
function log::info() {
    local message="$1"
    >&2 echo -e "${COLOR_GREEN}[info]${COLOR_DEFAULT} $message"
}

function log::error() {
    local message="$1"
    >&2 echo -e "${COLOR_RED}[error]${COLOR_DEFAULT} $message"
    exit 1
}

# Microservice functions
function microservice::deploy() {
    local microservice_path="$1"
    local microservice_project="$2"

    >/dev/null pushd "$microservice_path"
    docker-compose --project-name "$microservice_project" \
                   --file docker-compose.db.yml \
                   up -d --build
    >/dev/null popd
}

function microservice::destroy() {
    local microservice_path="$1"
    local microservice_project="$2"

    >/dev/null pushd "$microservice_path"
    docker-compose --project-name "$microservice_project" \
                   --file docker-compose.db.yml \
                  rm --stop -v --force
    >/dev/null popd
}

# API Live Creator functions
function api_live_creator::deploy() {
    local path="$1"
    local project="$2"
    local node_scale="$3"

    >/dev/null pushd "$path"
    docker-compose --project-name "$project" \
                   --file docker-compose.yml \
                   --file docker-compose.db.yml \
                   up -d --build --scale "lac-node=$node_scale"
    >/dev/null popd
}

function api_live_creator::wait() {
    local retry="$1"
    local host="$2"
    local user="$3"
    local password="$4"

    local is_up=false
    for i in $(seq 1 "$retry"); do
      if lacadmin login \
                    --username "$user" \
                    --password "$password" \
                    "$host" &>/dev/null; then
        is_up=true
        break
      fi
      sleep 1
    done

    if ! $is_up; then
      log::error "API Live Creator didn't start within $retry retries."
    fi
}

function api_live_creator::destroy() {
    local path="$1"
    local project="$2"

    >/dev/null pushd "$path"
    docker-compose --project-name "$project" \
                   --file docker-compose.yml \
                   --file docker-compose.db.yml \
                   rm --stop -v --force
    >/dev/null popd
}

function api_live_creator::login() {
    local host="$1"
    local user="$2"
    local password="$3"
    local server_alias="$4"

    lacadmin login --username "$user" \
                   --password "$password" \
                   --serverAlias "$server_alias" \
                   "$host"
}

function api_live_creator::create_api() {
    local api_json_path="$1"
    local datasource_prefix="$2"
    local datasource_password="$3"

    lacadmin project import --file "$api_json_path"
    lacadmin datasource update --prefix "$datasource_prefix" \
                               --password "$datasource_password"
}

# Microgateway functions
function microgateway::deploy() {
  local path="$1"
  local path_addons="$2"
  local project="$3"
  local ssg_scale="$4"
  local db_type="$5"
  local path_customization="$6"

  if [ ! -d "${path}/add-ons.orig" ]; then
    mv "${path}/add-ons" "${path}/add-ons.orig"
  fi

  if [ -d "${path}/add-ons" ]; then
    rm -r "${path}/add-ons"
  fi

  cp -r "${path_addons}" "${path}/add-ons"
  cp "${path}/add-ons.orig/Dockerfile.addon" "${path}/add-ons/"

  local docker_compose_options=""
  if [ "$db_type" != "" ]; then
    docker_compose_options=("--file" "${path}/docker-compose.db.${db_type}.yml")
  fi

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 --file "${path}/docker-compose.lb.dockercloud.yml" \
                 --file "${path}/docker-compose.addons.yml" \
                 --file "${path_customization}/docker-compose.solutionkit.policysdk.yml" \
                 --file "${path_customization}/docker-compose.customize.yml" \
                 "${docker_compose_options[@]}" \
                 up -d --build --scale "ssg=${ssg_scale}"
}

function microgateway::destroy() {
  local path="$1"
  local path_addons="$2"
  local project="$3"
  local db_type="$4"

  if [ -d "${path}/add-ons.orig" ]; then
    if [ -d "${path}/add-ons" ]; then
        rm -r "${path}/add-ons"
    fi
    mv "${path}/add-ons.orig" "${path}/add-ons"
  fi

  local docker_compose_options=""
  if [ "$db_type" != "" ]; then
    docker_compose_options=("--file" "${path}/docker-compose.db.${db_type}.yml")
  fi

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 --file "${path}/docker-compose.lb.dockercloud.yml" \
                 --file "${path}/docker-compose.addons.yml" \
                 "${docker_compose_options[@]}" \
                 rm --stop -v --force

  if [ "$db_type" == "consul" ]; then
    docker volume rm --force "${project}_consul"
  fi
}

function microgateway::beta::enable_mtls() {
    # username, password: RESTMan credentials
    # entity: service or policy
    # entity_name: the name of the service or policy to update
    local compose_service="$1"
    local compose_project="$2"
    local compose_base_path="$3"
    local gw_username="$4"
    local gw_password="$5"
    local gw_entity="$6"
    local gw_entity_name="$7"

    local container_counter=0
    for i in $(docker-compose --project-name "$compose_project" \
                              --file "${compose_base_path}/docker-compose.yml" \
                              ps -q "$compose_service"); do

      container_counter=$(($container_counter + 1))
      docker-compose --project-name "$compose_project" \
                     --file "${compose_base_path}/docker-compose.yml" \
                     exec --index=$container_counter "$compose_service" \
                     curl --insecure "https://localhost:8443/darrin/updaterouting?username=${gw_username}&password=${gw_password}&entity=${gw_entity}&entity_name=${gw_entity_name}"
    done
}

# Ingress Gateway functions
function ingress_gateway::deploy {
  local path="$1"
  local project="$2"
  local db_type="$3"

  local docker_compose_options=""
  if [ "$db_type" != "" ]; then
    docker_compose_options=("--file" "${path}/docker-compose.db.${db_type}.yml")
  fi

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 --file "${path}/docker-compose.addons.yml" \
                 "${docker_compose_options[@]}" \
                 up -d --build
}

function ingress_gateway::destroy {
  local path="$1"
  local project="$2"
  local db_type="$3"

  local docker_compose_options=""
  if [ "$db_type" != "" ]; then
    docker_compose_options=("--file" "${path}/docker-compose.db.${db_type}.yml")
  fi

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 --file "${path}/docker-compose.addons.yml" \
                 "${docker_compose_options[@]}" \
                 rm --stop -v --force

  if [ "$db_type" == "consul" ]; then
    docker volume rm --force "${project}_consul"
  fi
}

# OTK functions
function otk::solutionkit::add() {
    local source_path="$1"
    local dest_path="$2"

    cp "$source_path" "$dest_path"
}

function otk::solutionkit::remove() {
    local path="$1"

    if [ -f "$path" ]; then
      rm "$path"
    fi
}

function otk::deploy() {
  local path="$1"
  local project="$2"

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 up -d --build
}

function otk::destroy() {
  local path="$1"
  local project="$2"

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 rm --stop -v --force
}

# MQTT functions
function mqtt::deploy() {
  local path="$1"
  local project="$2"
  local scale="$3"

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 up -d --build --scale "mqtt=${scale}"
}

function mqtt::destroy() {
  local path="$1"
  local project="$2"

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 rm --stop -v --force
}

# Docker functions
function docker::network::create() {
  local name="$1"
  if [ "$(docker network ls --quiet --filter "name=${name}" | wc -l)" -eq 0 ]; then
    docker network create "${name}"
  fi
}

function docker::network::rm() {
  local name="$1"
  if [ "$(docker network ls --quiet --filter "name=${name}" | wc -l)" -eq 1 ]; then
    docker network rm "${name}"
  fi
}

function docker::wait_healthy() {
  local container_name="$1"
  local timeout="$2"

  local is_up=false
  local counter=0

  while [ "$counter" -lt "$timeout" ]; do
    if docker ps --filter "name=${container_name}" \
       | grep --only \
              --extended-regexp "\(healthy\)"; then

      is_up=true
      break
    fi
    sleep 1
    counter=$(($counter + 1))
  done

  if ! $is_up; then
    log::error "The container $container_name was not healthy within $timeout seconds."
  fi
}

function docker::wait_all_healthy() {
  local timeout="$1"

  local is_up=false
  local counter=0

  while [ "$counter" -lt "$timeout" ]; do
    log::info "Waiting for:"
    if ! docker ps --format "table {{.Names}}\t{{.Status}}" \
       | grep --extended-regexp "\(.*\)" \
       | grep --only \
              --invert-match --extended-regexp "\(healthy\)"; then

        is_up=true
        break
    fi
    sleep 1
    counter=$(($counter + 1))
  done

  if ! $is_up; then
    log::error "The services were not healthy within $timeout seconds."
  fi
}

function docker::check_project_up() {
  local project="$1"
  if docker ps --all \
               --format "table {{.Names}}\t{{.Status}}" \
               --filter "name=${project}_" \
               | grep "Exited"; then

    log::error "Some containers exited. This might be because of
a license that was not accepted or because of resource limitation
(memory, CPU, disk space). Please double check the README.md
then re-run this script."
  fi
}

# Licnse
function license::set() {
  local license_path="${1}"
  local license_accept_value="${2}"

  echo "$license_accept_value" > "$license_path"
}

# Other functions
function check::required_cli() {
    command -v docker-compose 2>&1 || log::error "Command docker-compose not found."
    command -v docker         2>&1 || log::error "Command docker not found."
    command -v lacadmin       2>&1 || log::error "Command lacadmin not found."
    command -v sleep          2>&1 || log::error "Command sleep not found."
}

function check::required_version() {
  local cli_name="${1}"
  local cli_version="${2}"
  local required_version="${3}"

  local cli_version_normalized="$(echo "$cli_version" | tr -d ".")"
  local required_version_normalized="$(echo "$required_version" | tr -d ".")"

  if [ "$cli_version_normalized" -lt "$required_version_normalized" ]; then
    log::error "Please upgrade $cli_name at least to version $required_version (found version $cli_version)"
  fi
}

function check::accepted_license() {
  local license_file="${1}"
  local expected_value="${2}"

  if ! grep -E "^${expected_value}$" "${license_file}"; then
    log::error "Expecting ${expected_value} in the file ${license_file}"
  fi
}

# Start the main function
main "$@"
