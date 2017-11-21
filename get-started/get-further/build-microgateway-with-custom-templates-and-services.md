## Build a Microgateway image with APIs preloaded from JSON file

This step will typically be done by a devops engineer.

- **_Accept the license_**

  By passing the value "true" to the environment variable `ACCEPT_LICENSE` in
  the file `get-started/docker-compose/config/license.env`, you are expressing
  your acceptance of the [CA Trial and Demonstration Agreement](../../LICENSE.md).

  The initial Product Availability Period for your trial of CA Microgateway
  shall be sixty (60) days from the date of your initial deployment. You are
  permitted only one (1) trial of CA Microgateway per Company, and you may not
  redeploy a new trial of CA Microgateway after the end of the initial Product
  Availability Period.

- Build a new Microgateway container image with a sample service:

  - _A sample service json is under `get-started/docker-compose/add-ons/services`_
  - _Run the following command to build a new image with the sample template and service and start the Microgateway_

  ```
  cd get-started/docker-compose

  docker-compose --project-name microgateway \
                 --file docker-compose.yml \
                 --file docker-compose.lb.dockercloud.yml \
                 --file docker-compose.addons.yml \
                 up -d --build
  ```

- Verify that your API is exposed:

  ```
  curl --insecure --user "admin:password" https://localhost/quickstart/1.0/services
  ```
  Should return a list containing your Google Search Preloaded service.

- Use your exposed API:

  ```
  curl --insecure \
       --header "User-Agent: Mozilla/5.0" \
       'https://localhost/google-preloaded?q=CA'
  ```
- Find your new microgateway image

  ```
  docker images caapim/microgateway:addons
  ```

Underneath the hood:

- When setting `SCALER_ENABLE: "false"`, microgateway will load quickstart services from json files under /opt/SecureSpan/Gateway/node/default/etc/bootstrap/qs inside the container. The user could choose to bake the quickstart json files using a Dockerfile (e.g. `get-started/docker-compose/add-ons/Dockerfile.addon`) into the container or map the docker volume to a folder.  

Integration to CI/CD:

- The devops engineer could incorporate the docker container build process to overall CI/CD infrastructure by storing the quickstart .json files in a (git) repository and use docker build tools such as https://wiki.jenkins.io/display/JENKINS/Docker+build+step+plugin to build new container image
