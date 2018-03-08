# Prerequisites
kubectl CLI is installed on the machine 
kube config file is configured on the machine. The file should be present at ~/.kube/config. This file contains the credentials and server details of kubernetes setup

# Deployment types
The following deployments are currently supported
	1) MSGW with Consul
	2) MSGW with Database
	3) MSGW (Immutable Mode)

### Configure variables:
The folder consists of 4 deployment related files
	1) config.yaml which contains all the configurations settings (For more details on variables, refer [https://github-isl-01.ca.com/APIM-Gateway/twelvefactorgateway/tree/openshift-deployment#configure])
	2) postgres.yaml which deploys a postgres database
	3) consul.yaml which deploys consul server
	4) msgw.yaml which deploys the Microgateway Service

### Deploy
- Accept the license

  To accept the license agreement [Microservices Gateway Pre-Release Agreement], set the value of "accept.license" to true. This variable is present in configmap "licenseconfig" in config.yaml file.

- Start
```
kubectl apply -f config.yml -f db-consul.yml -f microgateway.yml (to deploy with consul configuration. Requires "quickstart.rest.mode" set to "true" and "quickstart.respository.type" set to "consul")
```
```
kubectl apply -f config.yml -f db-postgresql.yml -f microgateway.yml (to deploy with postgres configuration. Requires "quickstart.rest.mode" set to "true" and "quickstart.respository.type" set to "db")
```
```
kubectl apply -f config.yml -f microgateway.yml (to deploy with microgateway in immutable configuration. Requires "quickstart.rest.mode" set to "false")
```

#### DNS Settings
Map the the microgateway route to the Kubernetes external IP by editing `/etc/hosts` with the following content:
```
<KUBERNETES PUBLIC IP> microgateway.mycompany.com
```
with:
- `<KUBERNETES PUBLIC IP>`: the public IP address of your Kubernetes machine