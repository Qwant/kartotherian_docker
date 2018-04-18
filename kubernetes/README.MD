## Kubernates

### How to start (with minikube)

```
$ minicube start --vm-driver=none
$ kubectl create -f ./kubernetes/
```

### Side notes

>How to exec  popuate-posgres shell inside pbfs pod
```
kubectl exec -it pbfs --container=populate-postgres sh
```

### Configurations files
load_db.pod 
 - pbfpod (download pbf)
 - populate-postgres (start load_db script)
 
 these two containers shares pbfs volume located (/tmp/pbfs)
 
 postgres.rc
  - replicate {one} postgres pod (should be a static set or whatever)
 
 postgres.service
  - serve postgres as a service
  
  
### TODO
 - start load db ""job""
 