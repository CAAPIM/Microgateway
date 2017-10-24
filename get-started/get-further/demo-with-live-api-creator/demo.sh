#!/bin/bash
set -o errexit  # Exit if a command fails
set -o pipefail # Exit if one command in a pipeline fails
set -o nounset  # Treat  unset  variables and parameters as errors

CWD="$(cd "$(dirname "$0")" && pwd)" # Script directory
[ "${DEMO_DEBUG:-0}" -eq 1 ] && set -o xtrace

# Configuration
START_TIMEOUT="600"
DOCKER_PROJECT_NAME="demo" # do not change
MICROSERVICE_BASE_PATH="${CWD}/microservices"

API_LIVE_CREATOR_PATH="${CWD}/api-live-creator"
API_LIVE_CREATOR_USER="admin"
API_LIVE_CREATOR_PASSWORD="Password1"
API_LIVE_CREATOR_HOST="http://localhost:8111"
API_LIVE_CREATOR_NODES="1"
API_LIVE_CREATOR_SERVER_ALIAS="lac_cluster"
API_LIVE_CREATOR_RETRY_TIMEOUT="60" # In seconds

MICROGATEWAY_PATH="${CWD}/../../docker-compose"
MICROGATEWAY_PATH_ADDONS="${CWD}/microgateway/add-ons"
MICROGATEWAY_PATH_CUSTOMIZATION="${CWD}/microgateway/customization"
MICROGATEWAY_SSG_SCALE="1"
MICROGATEWAY_DB_TYPE="consul" # postgresql or consul or empty (leave empty for the immutable mode)

INGRESS_GATEWAY_PATH="${CWD}/gateway"

OTK_HOST="localhost:8443"
OTK_USERNAME="admin"
OTK_PASSWORD="password"
OTK_PATH="${CWD}/../../external/otk"
OTK_SOLUTIONKIT_POLICYSDK_PATH="${CWD}/otk/solutionkits/PolicySDK-v1.0.0.00.skmult"

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

            log::info "Deploying the database of the microservice Orders"
            microservice::deploy "${MICROSERVICE_BASE_PATH}/orders" "$DOCKER_PROJECT_NAME"

            log::info "Deploying the database of the microservice Recommendation"
            microservice::deploy "${MICROSERVICE_BASE_PATH}/recommendation" "$DOCKER_PROJECT_NAME"

            log::info "Deploying CA OTK"
            otk::solutionkit::add "$OTK_SOLUTIONKIT_POLICYSDK_PATH" "$OTK_PATH/solutionkits/"
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

            log::info "Destroying CA OTK"
            otk::destroy "$OTK_PATH" "$DOCKER_PROJECT_NAME"
            otk::solutionkit::remove "$OTK_PATH/solutionkits/$(basename $OTK_SOLUTIONKIT_POLICYSDK_PATH)"

            log::info "Removing the Docker network ${DOCKER_PROJECT_NAME}_default"
            docker::network::rm "${DOCKER_PROJECT_NAME}_default"

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
    echo -e "${COLOR_GREEN}[info]${COLOR_DEFAULT} $message"
}

function log::error() {
    local message="$1"
    echo -e "${COLOR_RED}[error]${COLOR_DEFAULT} $message"
    exit 1
}

trap 'log::error ${LINENO}' ERR

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
    for i in $(seq 1 $retry); do
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
    docker_compose_options="--file ${path}/docker-compose.db.${db_type}.yml"
  fi

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 --file "${path}/docker-compose.lb.dockercloud.yml" \
                 --file "${path}/docker-compose.addons.yml" \
                 --file "${path_customization}/docker-compose.solutionkit.policysdk.yml" \
                 --file "${path_customization}/docker-compose.customize.yml" \
                 $docker_compose_options \
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
    docker_compose_options="--file ${path}/docker-compose.db.${db_type}.yml"
  fi

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 --file "${path}/docker-compose.lb.dockercloud.yml" \
                 --file "${path}/docker-compose.addons.yml" \
                 $docker_compose_options \
                 rm --stop -v --force
}

# Ingress Gateway functions
function ingress_gateway::deploy {
  local path="$1"
  local project="$2"

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 --file "${path}/docker-compose.db.postgresql.yml" \
                 up -d --build
}

function ingress_gateway::destroy {
  local path="$1"
  local project="$2"

  docker-compose --project-name "$project" \
                 --file "${path}/docker-compose.yml" \
                 --file "${path}/docker-compose.db.postgresql.yml" \
                 rm --stop -v --force
}

# OTK functions
function otk::solutionkit::add() {
    local source_path="$1"
    local dest_path="$2"

    cp $source_path $dest_path
}

function otk::solutionkit::remove() {
    local path="$1"

    if [ -f "$path" ]; then
      rm $path
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

function otk::add_otk_user() {
  local path="$1"
  local otk_host="$2"
  local otk_user="$3"
  local otk_password="$4"
  local gw_hostname="$5"
  local gw_certificate="$6"

  ${path}/provision/add-otk-user.sh "$otk_host" "$otk_user" "$otk_password" \
                                    "Gateway as a Client Identity Provider" \
                                    "$gw_hostname" \
                                    "$gw_certificate"
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
  for i in $(seq 1 $timeout); do
    if docker ps --filter "name=${container_name}" \
       | grep --only \
              --extended-regexp "\(healthy\)"; then

      is_up=true
      break
    fi
    sleep 1
  done

  if ! $is_up; then
    log::error "The container $container_name was not healthy within $timeout seconds."
  fi
}

function docker::wait_all_healthy() {
  local timeout="$1"

  local is_up=false
  for i in $(seq 1 $timeout); do
    log::info "Waiting for:"
    if ! docker ps --format "table {{.Names}}\t{{.Status}}" \
       | grep --extended-regexp "\(.*\)" \
       | grep --only \
              --invert-match --extended-regexp "\(healthy\)"; then

        is_up=true
        break
    fi
    sleep 1
  done

  if ! $is_up; then
    log::error "The services were not healthy within $timeout seconds."
  fi
}

# Other functions
function check::required_cli() {
    command -v docker-compose
    command -v docker
    command -v lacadmin
    command -v sleep
}

# Start the main function
main "$@"
