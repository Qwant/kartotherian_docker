## Kubernetes

### How to start (with minikube)

**1.** Install minikube, kubectl and vm driver (https://github.com/kubernetes/minikube#installation)

**2.** Start minikube

```
$ minikube start --vm-driver=kvm2 --disk-size=30g
```
> Or using data from a local directory:  
```
$ minikube start --vm-driver=kvm2 --disk-size=30g --mount --mount-string "./data:/data"
```

**3.** Label the minikube node to host the maps data importer

```
$ kubectl label nodes minikube maps-pg-importer=true
```

**4.** Apply kubernetes configuration files
```
$ kubectl apply -f ./kubernetes/
```


### Configurations files

configmap.yml
 - a default configuration for jobs and services

load_db.job.yml
 - downloads a pbf (url set in configmap.yml)
 - runs the import to postgres
 
postgres.yml
 - defines postgres replication controller
 - serves postgres as a service
  
