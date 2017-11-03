## Microgateway on Docker: configure, install, upgrade, scale and more

* [Prerequisites](#prerequisites)
* [Deployment diagram](#diagram)
* [Operation commands](#ops-commands)
  * [Configure](#configure)
  * [Install](#install)
  * [Update](#upgrade)
  * [Scale up/down](#scale)
  * [Logs](#logs)
  * [Health Check](#health-check)
  * [Uninstall](#uninstall)

### Prerequisites <a name="prerequisites"></a>
- A machine running the Docker daemon, which can be:
  - a laptop with Docker installed (https://www.docker.com/community-edition)
  - a Docker Machine (https://docs.docker.com/machine/overview/) which will deploy
  a virtual machine on a supported platforms with Docker preinstalled
  - a bare-metal or virtual machine provisioned with Docker

- Docker Compose (https://docs.docker.com/compose) to operate the Microgateway on Docker

### Deployment diagram <a name="diagram"></a>

[microgateway-on-docker]: img/docker_draw.io.png "Microgateway on Docker"
![alt text][microgateway-on-docker]

The Microgateway cluster running on the Docker host is composed of multiple
Docker containers synchronizing exposed API definitions with a database or a
key/value store.

The load balancer distributes the workloads across the Microgateway cluster.

*Note: The load balancer, database/KV store, and microservices can optionally
run in the same Docker machine as the Microgateway.*

### Operation commands <a name="ops-commands"></a>

#### Configure <a name="configure"></a>

*Note 1: Please refer to the main documentation for the list of required and optional
environment variables: https://docops.ca.com/ca-microgateway/1-0/EN.*

*Note 2: By passing the value "true" to the environment variable `ACCEPT_LICENSE`
in the file `get-started/docker-compose/config/license.env`, you are expressing
your acceptance of the [CA Trial and Demonstration Agreement](LICENSE.md). The
initial Product Availability Period for your trial of CA Microgateway shall be
sixty (60) days from the date of your initial deployment. You are permitted only
one (1) trial of CA Microgateway per Company, and you may not redeploy a new
trial of CA Microgateway after the end of the initial Product Availability Period.*

The environment variables of the Microgateway are set in the docker-compose.yml
file. Here is an example setting the environment variables `CLUSTER_PROPERTY_cluster_hostname`
and `ACCEPT_LICENSE` in the Docker container of the Microgateway.

```
services:
  microgateway:
    image: caapimcollab/microgateway:beta2
    environment:
      CLUSTER_PROPERTY_cluster_hostname: "apis.mycompany.com"
      ACCEPT_LICENSE: "true"
```

Another option is to pass environment variables from external files to separate
the Docker container configuration (like the source image, memory and CPU) and the
Microgateway configuration.

```
services:
  microgateway:
    image: caapimcollab/microgateway:beta2
    env_file:
      - ./config/db.env
      - ./config/license.env
```

With the files:
- ./config/db.env
```
SCALER_ENABLE=true
SCALER_STORAGE_TYPE=db
SCALER_DB_TYPE=postgresql
SCALER_DB_HOST=cadbhost
SCALER_DB_PORT=5432
SCALER_DB_NAME=qstr
SCALER_DB_USER=causer
```

- ./config/license.env
```
ACCEPT_LICENSE=true
```

#### Install <a name="install"></a>

```
docker-compose --file docker-compose.yml up -d --build
```

You can use multiple `--file` if you have more than one Docker Compose yaml file
extending or adding new services to `docker-compose.yml`.

#### Update <a name="upgrade"></a>

Write the new configuration in the `docker-compose.yml` file and environment files
(e.g. `./config/db.env`), then re-run the `docker-compose up` command. Docker
Compose will redeploy only the updated services.

#### Scale up/down <a name="scale"></a>

```
docker-compose --file docker-compose.yml up -d --scale SERVICE=NUMBER
```
With:
- SERVICE: the name of the Microgateway service in docker-compose.yml
- NUMBER: the number of Microgateway to deploy

#### Logs <a name="logs"></a>

- Print logs:
  ```
  docker-compose logs --file docker-compose.yml logs --follow
  ```
  Will print the logs of all services defined in `docker-compose.yml`.

  ```
  docker-compose logs --file docker-compose.yml logs --follow microgateway
  ```
  Will print the logs of the service named `microgateway` defined in `docker-compose.yml`.

- Aggregating logs:

  The logs of the Microgateway containers can be sent to an external logging system
  supported by Docker (https://docs.docker.com/engine/admin/logging/overview/#supported-logging-drivers)
  enabling log analytics.

  The following example is sending the Microgateway logs to the syslog server
  `syslog.domain.com` on port `514`.

  ```
  services:
    microgateway:
      image: caapimcollab/microgateway:beta2
      logging:
        driver: syslog
        options:
          syslog-address: "tcp://syslog.domain.com:514"
  ```

#### Health check <a name="health-check"></a>

```
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Will return the list of Docker containers with their associated status

```
NAMES                      STATUS
dockercompose_proxy_1      Up 29 minutes
dockercompose_ssg_1        Up 29 minutes (healthy)
dockercompose_cadbhost_1   Up 29 minutes
```

More formatting can be found at https://docs.docker.com/engine/reference/commandline/ps/#formatting

The command `docker inspect` can be used to extract more information about the
health and status of containers. In the following example, it inspects the state
of all running containers and extracts the name and health status.

```
docker inspect $(docker ps -qa) | jq '.[] | "\(.Name);\(.State.Health.Status)"'

"/dockercompose_proxy_1;null"
"/dockercompose_ssg_1;healthy"
"/dockercompose_cadbhost_1;null"
```

#### Uninstall <a name="uninstall"></a>

```
docker-compose --file docker-compose.yml down --volumes
```

Will remove all the resources defined the `docker-compose.yml` file.
