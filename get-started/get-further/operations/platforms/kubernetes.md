## CA Microgateway on Kubernetes: configure, install, upgrade, scale and more

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
 - A machine running the Kubernetes cluster with a minimum 4GB of memory:
    - Minikube on a laptop (https://github.com/kubernetes/minikube)

      ```
      minikube start --cpus 4 --memory 6144
      ```

    - Any other Kubernetes (https://kubernetes.io/docs/setup/pick-right-solution)
- Kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl) to operate the
CA Microgateway on Kubernetes
- Your Kubernetes credentials set in the file `~/.kube/config`

# Deployment diagram

[microgateway-on-kubernetes]: img/kubernetes_draw.io.png "CA Microgateway on Kubernetes"
![alt text][microgateway-on-kubernetes]

The CA Microgateway cluster running on Kubernetes is at least composed of:
- a Kubernetes route exposing the CA Microgateway service to users
- an Kubernetes service load balancing requests to the CA Microgateway containers
- Kubernetes pods hosting respectively a CA Microgateway container

CA Microgateway containers synchronize exposed API definitions with a database or a
key/value store.

*Note: The database/KV store and microservices can optionally run in the same
Minikube*

### Operation commands <a name="ops-commands"></a>


#### Configure <a name="configure"></a>
   Deployment related files
 - config.yml which contains all the configurations settings (../../../kubernetes/config.yml)
 - postgres.yml which deploys a postgres database(../../../kubernetes/postgres.yml)
 - consul.yml which deploys consul server(../../../kubernetes/consul.yml)
 - msgw.yml which deploys the Microgateway Service (../../../kubernetes/msgw.yml)
 
*Note: please refer to the main documentation for the list of required and optional

*Note 1: Please refer to the main documentation for the list of required and optional
environment variables: https://docops.ca.com/ca-microgateway/1-0/EN.*

*Note 2: By passing the value "true" to the key `accept.license`
in the file [config.yml](../../../samples/platforms/kubernetes/config.yml), you are expressing
your acceptance of the [CA Trial and Demonstration Agreement](../../../LICENSE.md). The
initial Product Availability Period for your trial of CA Microgateway shall be
sixty (60) days from the date of your initial deployment. You are permitted only
one (1) trial of CA Microgateway per Company, and you may not redeploy a new
trial of CA Microgateway after the end of the initial Product Availability Period.*

The Kubernetes configuration file for CA Microgateway: [config.yml](../../../samples/platforms/kubernetes/config.yml)

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


- Immutable CA Microgateway

```
kubectl apply -f config.yml -f msgw.yml 
```
(to deploy with microgateway in immutable configuration. Requires "quickstart.rest.mode" set to "false")

#### DNS Settings
Map the the CA Microgateway route to the Kubernetes external IP by editing `/etc/hosts` with the following content:
```
<KUBERNETES PUBLIC IP> microgateway.mycompany.com
```
with:
- `<KUBERNETES PUBLIC IP>`: the public IP address of your Kubernetes machine

To access the CA Microgateway, Kubernetes gives various options like hostNetwork, hostPort, NodePort, LoadBalancer and Ingress.
In this documentation, ingress is used to access the CA Microgateway

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
  - Using the Kubernetes YAML file (e.g. `microgateway.yml`)

  The `replicas` key of the Deployment configuration block sets the number of
  CA Microgateway pods to deploy:

  ```

    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
        name: microgateway-dc
        labels:
            app: microgateway
    spec:
    replicas: 1
  ```

  Then push the new configuration:
  ```
  kubectl apply -f microgateway.yml
  ```

  - Using the Kuberetes command line "kubectl":

  In the previous example, the deployment configuration is named `microgateway-dc`.
  Instead of pushing a new deployment configuration, the `kubectl autoscale` command can
  be used:

  ```
  kubectl scale -f microgateway.yml
  ```

- Autoscaling:

  Autoscaling is done by adding an Kubernetes element `HorizontalPodAutoscaler` to
  the Kubernets YML file (e.g. `microgateway.yml`).

  The following example scales up the Kubernetes Deployment Configuration
  `microgateway-dc` if the CPU reaches 80%.

  ```
  apiVersion: autoscaling/v1
  kind: HorizontalPodAutoscaler
  metadata:
    name: microgateway-hpa
  spec:
    scaleTargetRef:
      kind: Deployment
      name: microgateway-dc
    minReplicas: 1
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
  ```

  Then push the new configuration:
  ```
  kubectl apply -f microgateway.yml
  ```

  Details about autoscaling can be found at
  https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

#### Logs <a name="logs"></a>

- Print logs:

```
kubectl logs -f deployment/microgateway-dc
```
Where `microgateway-dc` is the name of our Deployment Configuration defined
in `microgateway.yml`.

#### Health check <a name="health-check"></a>


```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: microgateway-dc
  labels:
    app: microgateway
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
  - `microgateway-dc` is the name of our Deployment Configuration defined in `microgateway.yml`
  - `readinessProbe` determines if a container is ready to service requests
  - `livenessProbe` determines if a container is running properly to serve requests
  - `/opt/docker/rc.d/diagnostic/health_check.sh` is the Microgateway health check script running inside the container

Using Kubernetes command line(kubectl)

```
kubectl get deployments
```

Will return the list of Kubernetes deployments with their associated status

```
NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
consul-dc           1         1         1            1           21m
microgateway-dc     1         1         1            1           20m
```

Details about Kubernetes Application Health Check can be found at
https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/

#### Uninstall <a name="uninstall"></a>

```
kubectl delete -f microgateway.yml
```
or
```
kubectl delete deployment/microgateway-dc
```

```
minikube stop
minikube delete
```