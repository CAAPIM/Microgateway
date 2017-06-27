## Get started

Supported platforms:
- Linux
- MacOS

Steps:

* [Prerequisites](#prerequisites)
* [Deploy the APIM Gateway](#deploy)
* [Expose a microservice API](#api)

## Prerequisites <a name="prerequisites"></a>
- A docker host

  You can use Docker on your laptop or in the Cloud. Docker-machine
  (https://docs.docker.com/machine/drivers/) can be used as a quick way to deploy
  a remote Docker host.

  Run the following command to validate that you can reach your Docker host.
  ```
  docker info
  ```

## Deploy the APIM Gateway <a name="deploy"></a>

This step will typically be done by a Gateway sysadmin.

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
  docker-compose -f docker-compose.yml -f docker-compose.dockercloudproxy.yml down

  ```

## Expose a microservice API <a name="api"></a>

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
            "httpMethod" : "<Automatic>"
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
       https://localhost/google\?q\=CA
  ```

## Next steps:
- Get further to try more complex scenarios:
  - [Secure a microservice API with Basic Authentication](get-further/api-with-basic-auth.md)
  - [Secure a microservice API with OAuth](get-further/api-with-oauth.md)
