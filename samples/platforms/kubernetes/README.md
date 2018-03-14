# Prerequisites
kubectl CLI is installed on the machine 
kube config file is configured on the machine. The file should be present at ~/.kube/config. This file contains the credentials and server details of kubernetes setup

# Deployment types
The following deployments are currently supported
1. CA Microgateway with Consul
2. CA Microgateway with Database
3. CA Microgateway (Immutable Mode)

### Configure variables:
The folder consists of 4 deployment related files
- config.yml which contains all the configurations settings
 postgres.yml which deploys a postgres database
- consul.yml which deploys consul server
- microgateway.yml which deploys the Microgateway Service


### Accept the license
To accept the license agreement [Microservices Gateway Pre-Release Agreement](https://github-isl-01.ca.com/APIM-Gateway/ca-microgateway/blob/master/LICENSE.md), set the value of "ACCEPT_LICENSE" to true. This variable is present in configmap `microgateway-license` in config.yml file.

### Start
1. With Consul storate option
    ```
    kubectl apply -f config.yml -f db-consul.yml -f microgateway.yml 
    ```
2.  With Postgres storate option
    ```
    # from kubernetes/postgres folder
    docker-compose -f docker-compose-postgres.yaml up --build
    ```

    Then configure `db-postgresql.yml` 
    ```
    # this IP should be machine IP if Postgres container is running locally
    QUICKSTART_REPOSITORY_DB_HOST: "10.137.227.146"
    ```
    Finally
    ```
    # from kubernetes folder
    kubectl apply -f config.yml -f db-postgresql.yml -f microgateway.yml
    ```
3. Immutable mode
    ```
    kubectl apply -f config.yml -f microgateway.yml
    ```

#### DNS Settings
Map the the microgateway route to the Kubernetes external IP by editing `/etc/hosts` with the following content:
```
<KUBERNETES PUBLIC IP> microgateway.mycompany.com
```
with:
- `<KUBERNETES PUBLIC IP>`: the public IP address of your Kubernetes machine

#### Accessing CA Microgateway Service
Port `30443` is exposed to an enxternal network to reach services running on clusters. 
```
curl --insecure --user admin:password https://microgateway.mycompany.com:30443/quickstart/1.0/services
```
should return an empty list.

#### Want to get further?
Check the get-further folder for more details of [deployment](https://github-isl-01.ca.com/APIM-Gateway/ca-microgateway/blob/kubernetes-guides-2/get-started/get-further/operations/platforms/kubernetes.md#deploy).