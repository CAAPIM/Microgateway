# Microgateway protecting Live API Creator microservices

*  [Architecture](#)
    * [Backend microservice data source](#)
    * [Backend microservices](#)
    * [Authentication and authorization service](#)
    * [Microgateway](#)
* [License](#)
* [Start](#)
* [Update](#)
* [Stop / Destroy](#)
* [Debug mode](#)

## Architecture
### Backend microservice data source

One database service is used per microservice. In our demo, the microservice
`order` uses the database service `orders-db` and the microservice `recommendation`
used the database service `recommendation-db`

### Backend microservices

Microservices are created and operated by CA API Live Creator. It is configured with Mutual TLS Authentication which to accept connection from Microgateway nodes only.

Admin service: `lac-admin`

Microservices service: `lac-node`

### Authentication and authorization service

Operated by CA API Gateway OAuth Toolkit (CA OTK) to manage
OAuth client authentication and authorization. Additionally,
the plugin `PolicySDK` serves signed certificate to each Microgateway node based on the Microgateway OAuth client ID.

### Microgateway
Exposes and protect microservices APIs.

## License
### Live API Creator

Add you Live API Creator license to the folder `api-live-creator/etc/license/`
and name it `CA_Technologies_LiveAPI_License.json`.

### OTK

Accept license by passing the value "true" to the environment variable `ACCEPT_LICENSE` in
the OTK [license.env](../../external/otk/config/license.env) file.

### Microgateway

By passing the value "true" to the environment variable `ACCEPT_LICENSE` in
the file [license.env](../../docker-compose/config/license.env), you are expressing
your acceptance of the [Microservices Gateway Pre-Release Agreement](../../../LICENSE.md).

## Start
```
cd get-started/get-further/demo-with-live-api-creator
./demo.sh start
```

## Wait for the containers to be healthy
```
docker ps --format "table {{.Names}}\t{{.Status}}"
```
should return:
```
NAMES                      STATUS
demo_lb_1                  Up 21 minutes
demo_ssg_1                 Up 21 minutes (healthy)
demo_otk_1                 Up 23 minutes (healthy)
demo_otk_mysqldb_1         Up 23 minutes
demo_lac-admin_1           Up 23 minutes
demo_lac-node_1            Up 23 minutes
demo_lac_mysql_1           Up 23 minutes
demo_recommendation-db_1   Up 23 minutes
demo_orders-db_1           Up 23 minutes
```

## Update
Simply re-run the command from the "Start" section. Docker will only relaunch
modified configuration.

## Stop / Destroy
```
cd get-started/get-further/demo-with-live-api-creator
./demo.sh stop
```

## Debug mode
```
export DEMO_DEBUG=1
```

then run `demo.sh`.
