# ca-microgateway (Beta)
Repository containing artifacts for using the CA Microgateway

## What is CA Microgateway
CA Microgateway provides secure service mesh for microservices with rich functionalities of the [CA API gateway family](https://www.ca.com/us/products/api-management.html) including SSL/TLS, OAuth, service discovery packed in a docker container. You can easily extend the capabilities of CA Microgateway by building your own policy with existing policy building capability in the API gateway family.

```
(microservice A)-----(Microgateway) <-
                          |            \
                          |             \
                     (auth service)       --------> [firewall] (Edge API gateway) <--------->
                          |             /
                          |            /
(microservice B)-----(Microgateway) <-
```

### Benefits
* Secure microservices without writing the same code in every service
* Integrate with microservices pattern and infrastructure. e.g. Consul service registry
* Optimize internal and external client APIs and reduce API chattiness
* Optimize network traffic by providing caching, circuit breaking ...etc

### Related microservices patterns
* API gateway/Backend for Frontend: http://microservices.io/patterns/apigateway.html
* Access token: http://microservices.io/patterns/security/access-token.html

## Get started

Supported platforms:
- Linux
- MacOS

Steps:

* [Prerequisites](#prerequisites)
* [Deploy the Microgateway](#deploy)
* [Expose a microservice API](#api)

### Prerequisites <a name="prerequisites"></a>
- A docker host

  You can use Docker on your laptop or in the Cloud. Docker-machine
  (https://docs.docker.com/machine/drivers/) can be used as a quick way to deploy
  a remote Docker host.

  Run the following command to validate that you can reach your Docker host.
  ```
  docker info
  ```

### Deploy the Microgateway <a name="deploy"></a>

This step will typically be done by a Gateway sysadmin.

- Accept the license:
  
  By passing the value "true" to the environment variable `ACCEPT_LICENSE` in
  the file `get-started/docker-compose/docker-compose.yml`, you are expressing
  your acceptance of the [Microservices Gateway Pre-Release Agreement](LICENSE.md).
  
- Start the Gateway:

  ```
  cd get-started/docker-compose
  docker-compose -f docker-compose.yml -f docker-compose.dockercloudproxy.yml up -d --build
  ```

- Verify that the Gateway is running:

  ```
  curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
  ```
  Should return an empty list of services `[]` when ready.

- Scale up/down the Gateway:

  ```
  docker-compose -f docker-compose.yml -f docker-compose.dockercloudproxy.yml scale ssg=2

  ```
  The Gateway has no scaling limit because it is based on the [The Twelve-Factor App](https://12factor.net/).

- Stop the Gateway:

  ```
  docker-compose -f docker-compose.yml -f docker-compose.dockercloudproxy.yml down --volumes

  ```

### Expose a microservice API <a name="api"></a>

This step will typically be done by a microservice developer.

- Create a file named Gatewayfile with the following content:

  ```
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

## Next steps:
- Get further to try more complex scenarios:
  - [Secure a microservice API with Basic Authentication](get-started/get-further/api-with-basic-auth.md)
  - [Secure a microservice API with OAuth](get-started/get-further/api-with-oauth.md)
  - [Load a microservice API from JSON file](get-started/get-further/build-microgateway-with-custom-templates-and-services.md)
  - [Register the Google Root TLS certificate](get-started/get-further/register-google-tls-certificate.md)
  - [Orchestrate API with RouteOrchestrator](get-started/get-further/api-with-route-orchestrator.md)
  - [Extend Microgateway with new templates](get-started/docker-compose/add-ons/bundles/README.md)

- Read the documentation:
  - Quick Start Template Documentation - https://localhost/quickstart/1.0/doc on your local Microgateway
  - [CA Microgateway Documentation](https://docops.ca.com/ca-api-gateway/9-2/en/ca-microgateway-beta)
