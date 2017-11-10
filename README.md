# CA Microgateway

* [What is CA Microgateway](#intro)
  * [Benefits](#benefits)
  * [Related microservices patterns](#patterns)
* [Get started](#get-started)
  * [Prerequisites](#prerequisites)
  * [Deploy the Microgateway](#deploy)
  * [Expose a microservice API](#api)
* [Next steps](#next-steps)
  * [Get further to try more complex scenarios](#get-further)
  * [Documentation](#documentation)

## What is CA Microgateway <a name="intro"></a>
CA Microgateway provides secure service mesh for microservices with rich functionalities of the [CA API gateway family](https://www.ca.com/us/products/api-management.html) including SSL/TLS, OAuth, service discovery packed in a docker container. You can easily extend the capabilities of CA Microgateway by building your own policy with existing policy building capability in the API gateway family.

More features, including the Policy Manager, available in the [free trial version](https://www.ca.com/us/trials/ca-microgateway.html).

<p align="center">
<img src="img/ca-microgateway-diagram_draw-io.png" alt="CA Microgateway" title="CA Microgateway" />
</p>

### Benefits <a name="benefits"></a>
* Secure microservices without writing the same code in every service
* Integrate with microservices pattern and infrastructure. e.g. Consul service registry
* Optimize internal and external client APIs and reduce API chattiness
* Optimize network traffic by providing caching, circuit breaking ...etc

### Related microservices patterns <a name="patterns"></a>
* API gateway/Backend for Frontend: http://microservices.io/patterns/apigateway.html
* Access token: http://microservices.io/patterns/security/access-token.html

## Get started <a name="get-started"></a>

Supported platforms:
- Linux
- MacOS

### Prerequisites <a name="prerequisites"></a>
- A docker host

  You can use Docker on your laptop or in the Cloud. Docker-machine
  (https://docs.docker.com/machine/drivers/) can be used as a quick way to deploy
  a remote Docker host.

  Run the following command to validate that you can reach your Docker host.
  ```
  docker info
  ```

### Deploy the CA Microgateway <a name="deploy"></a>

This step will typically be done by a Gateway sysadmin.

- Accept the license:

  By passing the value "true" to the environment variable `ACCEPT_LICENSE` in
  the file `get-started/docker-compose/config/license-agreement.env`, you are expressing
  your acceptance of the [CA Trial and Demonstration Agreement](LICENSE.md).

  The initial Product Availability Period for your trial of CA Microgateway
  shall be sixty (60) days from the date of your initial deployment. You are
  permitted only one (1) trial of CA Microgateway per Company, and you may not
  redeploy a new trial of CA Microgateway after the end of the initial Product
  Availability Period.

- Start the Gateway:

  ```
  cd get-started/docker-compose

  docker-compose --project-name microgateway \
                 --file docker-compose.yml \
                 --file docker-compose.db.consul.yml \
                 --file docker-compose.lb.dockercloud.yml \
                 up -d --build
  ```

- Verify that the Gateway is healthy (May need to repeat the command to refresh status):

  ```
  docker ps --format "table {{.Names}}\t{{.Status}}"
  ```
  Should return:
  ```
  NAMES                STATUS
  microgateway_lb_1    Up About a minute
  microgateway_ssg_1   Up About a minute (healthy)
  microgateway_consul_1    Up About a minute
  ```

- Print the logs:

  ```
  docker-compose --project-name microgateway \
                 --file docker-compose.yml \
                 --file docker-compose.db.consul.yml \
                 --file docker-compose.lb.dockercloud.yml \
                 logs --follow
  ```

- Scale up/down the Gateway:

  ```
  docker-compose --project-name microgateway \
                 --file docker-compose.yml \
                 --file docker-compose.db.consul.yml \
                 --file docker-compose.lb.dockercloud.yml \
                 up -d --scale ssg=2
  ```
  The Gateway has no scaling limit because it is based on the [The Twelve-Factor App](https://12factor.net/).

- Stop the Gateway:

  ```
  docker-compose --project-name microgateway \
                 --file docker-compose.yml \
                 --file docker-compose.db.consul.yml \
                 --file docker-compose.lb.dockercloud.yml \
                 down --volumes
  ```

### Expose a microservice API <a name="api"></a>

This step will typically be done by a microservice developer.

- Create a file named Gatewayfile with the following content:

  ```json
  {
      "Service": {
      "name": "Google Search",
      "gatewayUri": "/google",
      "httpMethods": [ "get" ],
      "policy": [
        {
          "RouteHttp" : {
            "targetUrl": "http://www.google.com/search${request.url.query}",
            "httpMethod" : "Automatic"
          }
        }
      ]
    }
  }
  ```

- Add your API to the Gateway:

  ```
  curl --insecure \
       --user "admin:password" \
       --url https://localhost/quickstart/1.0/services \
       --data @Gatewayfile
  ```

- Verify that your API is exposed:

  ```
  curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
  ```
  Should return a list containing your Google Search service.


- Use your exposed API:

  ```
  curl --insecure \
       --header "User-Agent: Mozilla/5.0" \
       'https://localhost/google?q=CA'
  ```

## Next steps  <a name="next-steps"></a>

### Get further to try more complex scenarios  <a name="get-further"></a>

- [Secure a microservice API with Basic Authentication](get-started/get-further/api-with-basic-auth.md)
- [Secure a microservice API with OAuth](get-started/get-further/api-with-oauth.md)
- [Load a microservice API from JSON file](get-started/get-further/build-microgateway-with-custom-templates-and-services.md)
- [Register the Google Root TLS certificate](get-started/get-further/register-google-tls-certificate.md)
- [Orchestrate API with RouteOrchestrator](get-started/get-further/api-with-route-orchestrator.md)
- [Extend Microgateway with new templates](get-started/get-further/extend-microgateway-with-new-templates.md)
- Operations:
  - Install, configuration, upgrade and scale
    - [Docker](get-started/get-further/operations/platforms/docker.md)
    - [OpenShift](get-started/get-further/operations/platforms/openshift.md)
  - [Logging and auditing](get-started/get-further/operations/system/logging-auditing.md)
  - [Performance tuning](get-started/get-further/operations/system/performance.md)

### Samples
- [Microgateway APIs](samples/APIs)
- Plaforms:
  - [OpenShift](samples/platforms/openshift)

### Documentation  <a name="documentation"></a>

- Quick Start Template Documentation - https://localhost/quickstart/1.0/doc on your local Microgateway
- [CA Microgateway Documentation](https://docops.ca.com/ca-microgateway/1-0/EN)
