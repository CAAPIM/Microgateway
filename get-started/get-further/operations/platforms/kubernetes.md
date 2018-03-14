## CA Microgateway on Kubernetes: configure, install, upgrade, scale and more

Watch the demo!
[![asciicast](img/kubernetes_demo_thumbnail.png)](https://asciinema.org/a/UTvWrf4YEdzITeclhV4yAqvKP)

* [Prerequisites](#prerequisites)
* [Deployment diagram](#diagram)
* [Deploy](#deploy)
* [Operation commands](#ops-commands)
  * [Update strategies](#upgrade)
  * [Scale up/down](#scale)
  * [Autoscaling](#autoscaling)
  * [Logs](#logs)
  * [Health Check](#health-check)
  * [Uninstall](#uninstall)

### Prerequisites <a name="prerequisites"></a>
 - A machine running the Kubernetes cluster with a minimum 4GB of memory:
    - Minikube on a laptop (https://github.com/kubernetes/minikube)
    - Any other Kubernetes (https://kubernetes.io/docs/setup/pick-right-solution)
- Kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl) to operate the
CA Microgateway on Kubernetes
- Your Kubernetes credentials set in the file `~/.kube/config`

# Deployment diagram

[microgateway-on-kubernetes]: img/kubernetes_draw.io.png "CA Microgateway on Kubernetes"
![alt text][microgateway-on-kubernetes]

The CA Microgateway cluster running on Kubernetes is at least composed of:
- a Kubernetes route exposing the CA Microgateway service to users
- a Kubernetes service load balancing requests to the CA Microgateway containers
- Kubernetes pods hosting respectively a CA Microgateway container

CA Microgateway containers synchronize exposed API definitions with a database or a
key/value store.

*Note: The database/KV store and microservices can optionally run in the same
Kubernetes*

# Deploy  <a name="deploy"></a>

## 1. First, accept the license of the microgateway
Open config.yml and set `ACCEPT_LICENSE` value to `true`:
```
ACCEPT_LICENSE: "true"
```

*Note 1: Please refer to the main documentation for the list of required and optional
environment variables: https://docops.ca.com/ca-microgateway/1-0/EN.*

*Note 2: By passing the value "true" to the key `ACCEPT_LICENSE`
in the file config.yml, you are expressing
your acceptance of the CA Trial and Demonstration Agreement. The
initial Product Availability Period for your trial of CA Microgateway shall be
sixty (60) days from the date of your initial deployment. You are permitted only
one (1) trial of CA Microgateway per Company, and you may not redeploy a new
trial of CA Microgateway after the end of the initial Product Availability Period.*

## 2. Start single-node cluster in local environment: giving enough resource here
```
minikube start --cpus 4 --memory 6144
```

## 3. Start deployments of pods and services defined in yaml

Three deployment modes of the CA Microgateway are listed here.

1. CA Microgateway with Consul as a service datastore,
    ```
    kubectl apply --filename microgateway.yml --filename config.yml --filename db-consul.yml
    ```
2. CA Microgateway with PostgreSQL as a service datastore, or
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
3. Immutable CA Microgateway
    ```
    kubectl apply ---filename microgateway.yml --filename config.yml --filename immutable.yml
    ```

## 4. Check the status of deployments: wait for 3-5 minutes until "deploy/microgateway-dc" available column shows 1
```
watch kubectl get all
```

You can also check the web dashboard by:
```
Minikube dashboard
```

## 5. Get public IP of cluster node
```
minikube ip  
```

## 6. Add the public cluster IP and hostname mapping to the host file
```
echo "192.168.99.100 microgateway.mycompany.com" | sudo tee -a /etc/hosts
```

## 7. Verify you can reach the microgateway running in kubernetes cluster (note: https port of the exposed service is hard-coded in yaml to 30443)
### 7.1. First verify by reaching the IP
```
curl --insecure \
    --user "admin:password" \
    --url https://192.168.99.100:30443/quickstart/1.0/services
```

### 7.2. Then verify by reaching the hostname
```
curl --insecure \
    --user "admin:password" \
    --url https://microgateway.mycompany.com:30443/quickstart/1.0/services
```

## 8. Verify you can create a simple service to route to google in the microgateway
```
curl --insecure \
    --user "admin:password" \
    --url https://microgateway.mycompany.com:30443/quickstart/1.0/services \
    --data '{  
            "Service":{  
                    "name":"Google",
                    "gatewayUri":"/google",
                    "httpMethods":[  
                        "get"
                    ],
                    "policy":[  
                        {  
                            "RouteHttp":{  
                            "targetUrl":"http://www.google.com"
                            }
                        }
                    ]
                }
            }'
```

You should get:
```
{
   "success" : true,
   "message" : "Quickstart service created successfully. There may be a delay of 10 seconds before the service is available."
}
```

## 9. Verify the service endpoint created actually routes to google
```
curl --insecure \
    --location \
    --user "admin:password" \
    --url https://microgateway.mycompany.com:30443/google
```    

You should get HTML response:
```
<!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="en-CA"><head><met
```

## 10. Stop the cluster
```
minikube stop
```

## 11. Delete the cluster
```
minikube delete
```

# Operation commands <a name="ops-commands"></a>

The Kubernetes YAML files deploying CA Microgateway are located in the folder `/samples/platforms/kubernetes/`.

You might see that the microgateway doesn't become available after a few minutes. In that case, see what went wrong by getting logs from the pod/container by:
```
// i.e. kubectl logs POD_NAME
kubectl logs microgateway-dc-6dc7b56cd7-986m6
```

There might be null pointer exception, in which case it's likely that microgateway's license is not valid or expired or unset.

#### How to enable Ingress to proxy a traffic from external network to internal nodes
The microgateway container inside pods in a cluster is not accessible from outside the internal network. 
To access the CA Microgateway, Kubernetes gives various options like hostNetwork, hostPort, NodePort, LoadBalancer and Ingress to expose services to external network. In this documentation, NodePort is used to access the CA Microgateway.

Verify that `ingress` and `kube-dns` are both `enabled`:
```
minikube addons list
```

If `ingress` is disabled, make sure to enable it:
```
minikube addons enable ingress
```

#### Update <a name="upgrade"></a>

Write the new configuration in the configuration file `config.yml`, then re-run
the `kubectl apply` command. Apply command will redeploy only the updated services.

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

  Autoscaling is done by adding a Kubernetes element `HorizontalPodAutoscaler` to
  the Kubernetes YML file (e.g. `microgateway.yml`).

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