## Build a microgateway container with custom templates and quick start services <a name="api-basic-auth"></a>

This step will typically be done by a devops engineer.

- **_Accept the license_**

  - _Accept the license agreement by reading through the [Microservices Gateway Pre-Release Agreement](LICENSE.md)_
  - _Open the file `get-started/docker-compose/docker-compose.yml` and change the `ACCEPT_LICENSE` environment variable value from `"false"` to `"true"`_
  - _By passing the value `"true"` to the environment variable `ACCEPT_LICENSE`, you are expressing your acceptance of the [Microservices Gateway Pre-Release Agreement](LICENSE.md)._

- Build a new Gateway container with sample bundle and service:

  - _A sample bundle for consul integration and a sample service json are under `get-started/docker-compose/add-ons`_ 
  - _Run `docker-compose-build-ssg.yml` to build a new container with the sample template and service_
  
  ```
  cd get-started/docker-compose
  docker-compose -f docker-compose-build-ssg.yml -f docker-compose.dockercloudproxy.yml up -d --build
  ```
  
- Verify that your API is exposed:

  ```
  curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
  ```
  Should return a list containing your Google Search With Basic Auth service.

- Use your exposed API:

  ```
  curl --insecure \
       --user "admin:password" \
       --header "User-Agent: Mozilla/5.0" \
       'https://localhost/google-with-basic-auth?q=CA'
  ```
  
Underneath the hood"
- when `SCALER_ENABLE: "false"`, microgateway will load quickstart services from json files under /opt/SecureSpan/Gateway/node/default/etc/bootstrap/qs inside the container. The user could choose to bake the quickstart json files into the container or map the docker volume to a folder.  
