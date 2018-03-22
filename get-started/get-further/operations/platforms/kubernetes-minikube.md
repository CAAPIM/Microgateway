# Running Kubernetes Locally via Minikube

Documentation: https://kubernetes.io/docs/getting-started-guides/minikube/

## Start single-node cluster in local environment with enough resource
```
minikube start --cpus 4 --memory 6144
```

## Get the Kubernetes cluster public IP
```
minikube ip  
```

## Kubernetes web dashboard
```
minikube dashboard
```
