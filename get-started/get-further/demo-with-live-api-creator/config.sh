# Configuration

# The initial Product Availability Period for your trial of CA Microgateway
# shall be sixty (60) days from the date of your initial deployment. You
# are permitted only one (1) trial of CA Microgateway per Company, and you
# may not redeploy a new trial of CA Microgateway after the end of the initial
# Product Availability Period.
ACCEPT_LICENSE=false

START_TIMEOUT="600"
DOCKER_PROJECT_NAME="demo" # do not change
MICROSERVICE_BASE_PATH="${CWD}/microservices"

API_LIVE_CREATOR_PATH="${CWD}/live-api-creator"
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
MICROGATEWAY_USERNAME="admin"
MICROGATEWAY_PASSWORD="password"

INGRESS_GATEWAY_PATH="${CWD}/gateway"
INGRESS_GATEWAY_DB_TYPE="postgresql" # postgresql or consul or empty (leave empty for the immutable mode)
INGRESS_GATEWAY_USERNAME="admin"
INGRESS_GATEWAY_PASSWORD="password"

OTK_HOST="localhost:8443"
OTK_USERNAME="admin"
OTK_PASSWORD="password"
OTK_PATH="${CWD}/../../external/mag"

MQTT_PATH="${CWD}/mqtt"
MQTT_SCALE="0"

# Required tool version
CHECK_VERSION="true"
DOCKER_COMPOSE_MIN_VERSION="1.16.0"

DEMO_DEBUG=0
