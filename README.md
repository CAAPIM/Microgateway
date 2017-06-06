# ca-microgateway
Repository containing artifacts for using the CA Microgateway (current official name of the twelvefactorgateway/GW4MS)

## docker
The docker folder contains the artifacts needed to start the CA Microgateway along with its dependent containers

### docker-compose.yml
The docker-compose file for the CA Microgateway

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

## get-started
The folder contains instructions to get started with microgateway as a demo or exercise using basic auth and OAuth. Please read "get-started" document for details
