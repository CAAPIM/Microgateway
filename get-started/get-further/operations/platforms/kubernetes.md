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
Kubernetes*

### Operation commands <a name="ops-commands"></a>

The Kubernetes YAML files deploying CA Microgateway are located in the folder [/samples/platforms/kubernetes/](../../../samples/platforms/kubernetes/)

#### Configure <a name="configure"></a>

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

Three deployment modes of the CA Microgateway are listed here.

1. CA Microgateway with Consul as a service datastore,

  ```
  kubectl apply --filename microgateway.yml --filename config.yml --filename db-consul.yml
  ```

2. CA Microgateway with PostgreSQL as a service datastore, or

  ```
  kubectl apply --filename microgateway.yml --filename config.yml  --filename db-postgresql.yml
  ```

3. Immutable CA Microgateway

  ```
  kubectl apply ---filename microgateway.yml --filename config.yml --filename immutable.yml
  ```


Wait for a few miniutes for pods to get ready.
You can get status of deployments by: 
```
kubectl get deployments -o wide
```

and also check web dashboard by:
```
Minikube dashboard
```

You might see that microgateway doesn't become available after a few minutes. In that case, see what went wrong by getting logs from the pod/container by:
```
// i.e. kubectl logs deployment/DEPLOYMENT_NAME -c CONTAINER_NAME
kubectl logs deployment/microgateway-dc -c microgateway

// i.e. kubectl logs POD_NAME
kubectl logs microgateway-dc-6dc7b56cd7-986m6
```

There might be NPE, in which case it's likely that microgateway's license is not valid or expired or unset.

#### Add DNS Settings To Access A Service From Outside Network through Ingress
The microgateway container inside pods in a cluster is not accessble outside the internal network. 
To access the CA Microgateway, Kubernetes gives various options like hostNetwork, hostPort, NodePort, LoadBalancer and Ingress to expose services to external network. In this documentation, ingress is used to access the CA Microgateway.

_Currently, ingress's mapping of the microgateway in [microgateway.yml](https://github-isl-01.ca.com/APIM-Gateway/ca-microgateway/blob/kubernetes-guides-2/samples/platforms/kubernetes/microgateway.yml#L43) for host and backend service hardcodes the host name as `microgateway.mycompany.com`,
meaning you need to use this exact name._

First get the public IP of the node:
```
Minikube ip
```

Then map the the CA Microgateway host name to the Kubernetes external IP. Edit `/etc/hosts` (for Mac) with the following content:
```
<KUBERNETES PUBLIC IP> microgateway.mycompany.com
```
where:
- `<KUBERNETES PUBLIC IP>` is the public IP address of your Kubernetes machine

Then enable Ingress:

```
minikube addons enable ingress
```

Verify that the microgateway service is accessible:
```
curl http://microgateway.mycompany.com:443
```

Now that the microgateway is running in Kubernetes, we can publish and consume services.

Follow steps mentioned [here](https://github-isl-01.ca.com/APIM-Gateway/ca-microgateway) to expose microserverice API.

#### Update <a name="upgrade"></a>

Write the new configuration in the configuration file `config.yml`, then re-run
the `kubectl apply` command. Apply command  will redeploy only the updated services.

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
