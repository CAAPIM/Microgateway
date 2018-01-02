## Microgateway on Kubernetes via Minikube : configure, install, upgrade, scale and more

* [Prerequisites](#prerequisites)
* [Deployment diagram](#diagram)
* [Operation commands](#ops-commands)
  * [Configure](#configure)
  * [Install](#install)
  * [Update strategies](#upgrade)
  * [Scale up/down](#scale)
  * [Autoscaling](#autoscaling)
  * [Logs](#logs)
  * [Health Check](#health-check)
  * [Uninstall](#uninstall)

### Prerequisites <a name="prerequisites"></a>
 - A machine running the Kubernetes cluster, which can be:
    - a laptop with Kubernetes via Minikube installed (https://kubernetes.io/docs/tasks/tools/install-minikube)
- Kubectl (Kubernetes command-line tool) (https://kubernetes.io/docs/tasks/tools/install-kubectl) to operate the Microgateway on Docker
operate the Microgateway on Kubernetes via Minikube
- kube config file is configured on the machine. The file should be present at ~/.kube/config. This file contains the credentials and server details of kubernetes setup

# Deployment types
The following deployments are currently supported
-   MSGW with Consul
-   MSGW with Database
-   MSGW (Immutable Mode)

[microgateway-on-kubernetes]: img/kubernetes_draw.io.png "Microgateway on Kubernetes"
![alt text][microgateway-on-kubernetes]

The Microgateway cluster running on Minikube is at least composed of:
- a Kubernetes route exposing the Microgateway to users
- an Kubernetes service load balancing requests to the Microgateway containers
- Minikube pods hosting respectively a Microgateway container

Microgateway containers synchronize exposed API definitions with a database or a
key/value store.

*Note: The database/KV store and microservices can optionally run in the same
Minikube*

### Operation commands <a name="ops-commands"></a>

Note 1. - Accept the license
        
          To accept the license agreement [Microservices Gateway Pre-Release Agreement], set the value of "accept.license" to true. This variable is present in configmap "licenseconfig" in config.yaml file.


#### Configure <a name="configure"></a>
   Deployment related files
 - config.yml which contains all the configurations settings (../../../kubernetes/config.yml)
 - postgres.yml which deploys a postgres database(../../../kubernetes/postgres.yml)
 - consul.yml which deploys consul server(../../../kubernetes/consul.yml)
 - msgw.yml which deploys the Microgateway Service (../../../kubernetes/msgw.yml)
 
*Note: please refer to the main documentation for the list of required and optional
environment variables: https://docops.ca.com/ca-microgateway/1-0/EN.*

#### Install <a name="install"></a>
- Start Minikube
```
minikube start --memory=6000
```
as by default minikube is assigned 2G memory which is not sufficient to start microgteway

- MSGW with Consul

```
kubectl apply -f config.yml -f consul.yml -f msgw.yml
```
(to deploy with consul configuration. Requires "quickstart.rest.mode" set to "true" and "quickstart.respository.type" set to "consul")

-   MSGW with Database

```
kubectl apply -f config.yml -f postgresql.yml -f msgw.yml 
```
(to deploy with postgres configuration. Requires "quickstart.rest.mode" set to "true" and "quickstart.respository.type" set to "db")


-   MSGW (Immutable Mode)

```
kubectl apply -f config.yml -f msgw.yml 
```
(to deploy with microgateway in immutable configuration. Requires "quickstart.rest.mode" set to "false")

#### DNS Settings
Map the the microgateway route to the Kubernetes external IP by editing `/etc/hosts` with the following content:
```
<KUBERNETES PUBLIC IP> microgateway.mycompany.com
```
with:
- `<KUBERNETES PUBLIC IP>`: the public IP address of your Kubernetes machine

To access the microgteway , Kubernetes gives various options like hostNetwork, hostPort, NodePort, LoadBalancer and Ingress.
In this documentation , ingress is used to access the microgateway

```
minikube addons enable ingress
```
Follow steps mentioned to Expose microserverice API as mentioned at https://github-isl-01.ca.com/APIM-Gateway/ca-microgateway

#### Update <a name="upgrade"></a>

Write the new configuration in the `msgw.yml` file and config file `config.yml`
, then re-run the `kubectl apply ` command. Apply
command  will redeploy only the updated services.


#### Scale up/down <a name="scale"></a>

- Manual scaling:
  - Using the Kubernetes YAML file (e.g. `msgw.yml`)

  The `replicas` key of the Deployment configuration block sets the number of
  Microgateway pods to deploy:

  ```
 
    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
        name: msgw-dc
        labels:
            app: msgw
    spec:
    replicas: 1
  ```

  Then push the new configuration:
  ```
  kubectl apply -f msgw.yml
  ```

  - Using the Kuberetes command line "kubectl":

  In the previous example, the deployment configuration is named `msgw-dc`.
  Instead of pushing a new deployment configuration, the `kubectl autoscale` command can
  be used:

  ```
  kubectl scale -f msgw.yml
  ```

- Autoscaling:

  Autoscaling is done by adding an Kubernetes element `HorizontalPodAutoscaler` to
  the Kubernets YML file (e.g. `msgw.yml`).

  The following example scales up the Kubernetes Deployment Configuration
  `msgw-dc` if the CPU reaches 80%.

  ```
  apiVersion: autoscaling/v1
  kind: HorizontalPodAutoscaler
  metadata:
    name: msgw-hpa
  spec:
    scaleTargetRef:
      kind: Deployment
      name: msgw-dc
    minReplicas: 1
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
  ```

  Then push the new configuration:
  ```
  kubectl apply -f msgw.yml
  ```

  Details about autoscaling can be found at
  https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

#### Logs <a name="logs"></a>

- Print logs:

```
kubectl logs -f deployment/msgw-dc
```
Where `msgw-dc` is the name of our Deployment Configuration defined
in `msgw.yml`.

#### Health check <a name="health-check"></a>


```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: msgw-dc
  labels:
    app: msgw
spec:
containers:
- name: microgateway
  image: caapimcollab/microgateway:latest
  env:
    [...]

  ports:
    [...]

  readinessProbe:
    exec:
      command:
      - /opt/docker/rc.d/diagnostic/health_check.sh
    initialDelaySeconds: 480
    periodSeconds: 15
    timeoutSeconds: 1

  livenessProbe:
    exec:
      command:
      - /opt/docker/rc.d/diagnostic/health_check.sh
    initialDelaySeconds: 90
    periodSeconds: 15
    timeoutSeconds: 1
```
Where:
  - `msgw-dc` is the name of our Deployment Configuration defined in `msgw.yml`
  - `readinessProbe` determines if a container is ready to service requests
  - `livenessProbe` determines if a container is running properly to serve requests
  - `/opt/docker/rc.d/diagnostic/health_check.sh` is the Microgateway health check script running inside the container

Using Kubernetes command line(kubectl)

```
kubectl get deployments
```

Will return the list of Kubernetes deployments with their associated status

```
NAME        DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
consul-dc   1         1         1            1           21m
msgw-dc     1         1         1            1           20m
```

Details about Kubernetes Application Health Check can be found at
https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/

#### Uninstall <a name="uninstall"></a>

```
kubectl delete -f msgw.yml
```
or
```
kubectl delete deployment/msgw-dc
```

```
minikube stop
minikube delete
```