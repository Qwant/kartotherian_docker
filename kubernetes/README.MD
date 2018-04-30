## Kubernetes

### How to start (with minikube)

**1.** Install minikube, kubectl and vm driver (https://github.com/kubernetes/minikube#installation)

**2.** Start minikube

```bash
minikube start --vm-driver=kvm2 --disk-size=30g
```

> Or using data from a local directory:

```bash
minikube start --vm-driver=kvm2 --disk-size=30g --mount --mount-string "./data:/data"
```

**3.** Label the minikube node to host the maps data importer

```bash
kubectl label nodes minikube maps-pg-importer=true
```

**4.** Install [Helm](https://www.helm.sh/)

All is described in the [documentation](https://docs.helm.sh/using_helm/#installing-helm) but TL;DR:

```bash
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
& helm init
```

**5.**
Deploy qmap:

```bash
helm install . --name qmap
```

To deploy to production (given you have the permissions):

```bash
helm install . -f values_prod.yaml
```

to delete an old chart:

```bash
helm delete --purge qmap
```