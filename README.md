# Terraform Kube Okami

This Terraform project is intended to be used as a template for deploying an opinionated Kubernetes cluster. It's used by my own Okami101 cluster. It provides :

* Complete monitoring (Kube Prometheus Stack), logging (Loki), tracing (Tempo)
* Ingress routing via Traefik (load balanced mode) and certificates managed by cert-manager
* Many types of DB, including Redis, MySQL, PostgresSQL (cluster mode), Elasticseach
* UI web managers, as Portainer, PHPMyAdmin, PgAdmin
* Complete CI solution with Gitea, as well as custom private docker registry
* Some additional tools for my own needs (umami and redmine)

For proper install, it should be used on top of [Terraform Hcloud K3s](https://github.com/adr1enbe4udou1n/terraform-hcloud-k3s).

## Usage

### Prepare

Next you need to install some helm charts as well as CRDs.

```sh
# automatic upgrade
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml

# add cert-manager crds
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.crds.yaml

# add csi drivers
kubectl -n kube-system create secret generic hcloud --from-literal=token=xxx
kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/v2.9.0/deploy/kubernetes/hcloud-csi.yml
kubectl patch sc hcloud-volumes -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# monitor CRDs
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.77.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

# traefik CRDs
kubectl apply --server-side -k https://github.com/traefik/traefik-helm-chart/traefik/crds/

# cnpg CRDs
kubectl apply -k https://github.com/cloudnative-pg/cloudnative-pg/config/crd/ --server-side
```
