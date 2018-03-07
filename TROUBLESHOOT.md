- If you get an error `Server aborted the SSL handshake`, wait 30 seconds to 1 minute for the ssg container to launch.

- If you get an error `Failed to connect to otk.mycompany.com port 8443: Connection refused Failed at line X`, then try these commands to remove orphaned containers.

  ```
  docker-compose -f docker-compose.yml down --volumes
  ```

  And try this again:

  ```
  docker-compose up --build
  ```

- If you get an error `Failed to connect to localhost port 443: Connection refused`, then check if `dockercompose_proxy_1` container is running by:

  ```
  docker-compose ps
  ```

  To run the proxy container, run the following command from get-started/docker-compose directory:

  ```
  docker-compose -f docker-compose.yml -f docker-compose.dockercloudproxy.yml up -d --build
  ```

- If you get `Failed to connect to localhost port 8443: Connection refused`, make sure `otk_otk_1` container is running by:

  ```
  docker-compose ps
  ```

  If the otk container is not running, move to `get-started/external/otk` directory and run:

  ```
  docker-compose up --build –d
  ```

  You should now be able to access https://localhost:8443/oauth/manager.

- If the internal docker network conflicts with one of your network's subnets, add the following to `docker-compose.yml` at the same level as `version` and `services`:

  ```yaml
  networks:
    default:
      ipam:
        driver: default
        config:
          - subnet: 172.28.0.0/16 # set this to the CIDR for a subnet that won't conflict
  ```
