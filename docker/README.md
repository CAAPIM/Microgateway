This is a general documentation of how to use microgateway docker container. For more details, please go to README on the root folder and get-started

## docker
The docker folder contains the artifacts needed to start the CA Microgateway along with its dependent containers

### docker-compose.yml
The docker-compose file for the CA Microgateway

**_Accept the license_**
  - _Accept the license agreement by reading through the [Microservices Gateway Pre-Release Agreement](../LICENSE.md)_
  - _Open the file `docker/docker-compose.yml` and change the `ACCEPT_LICENSE` environment variable value from `"false"` to `"true"`_
  - _By passing the value `"true"` to the environment variable `ACCEPT_LICENSE`, you are expressing your acceptance of the [Microservices Gateway Pre-Release Agreement](../LICENSE.md)._

To start: `docker-compose up --build -d`

To stop: `docker-compose down --volumes`

    --volumes : removes the volume attached to the database container, so you can reset the scaler database

### Dockerfile.mysql
The Dockerfile for the scaler database container. This is used to build a container that contains the scaler database's schema

### scalerDbSchema.sql
Schema for the scaler database

## docker/add-ons
The docker/add-ons folder allows users to bake custom policy templates into CA Microgateway

modify docker-compose.yml:

comment

```
image: caapimcollab/microgateway:beta1
```

uncomment
```
   build:
     context: ./add-ons
     dockerfile: Dockerfile.addon
```
save and run `docker-compose up --build -d`

### Dockerfile.addon
The Docker file that bake the custom policy template bundles from docker/add-ons/bundles/* into CA Microgateway container
