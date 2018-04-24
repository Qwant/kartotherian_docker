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

**5.** When Tilerator is running, generate tiles (for instance tiles corresponding to Luxembourg)
```
$ kubectl exec tilerator-XXXXX -- curl -XPOST "http://localhost:16534/add?generatorId=substbasemap&storageId=basemap&zoom=11&x=1059&y=696&fromZoom=11&beforeZoom=16&keepJob=true&parts=8&deleteEmpty=true"
$ kubectl exec tilerator-XXXXX-- curl -XPOST "http://localhost:16534/add?generatorId=gen_poi&storageId=poi&zoom=11&x=1059&y=696&fromZoom=7&beforeZoom=15&keepJob=true&parts=8&deleteEmpty=true"
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
