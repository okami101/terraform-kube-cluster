# Terraform Kube Okami

This Terraform project is intended to be used as a template for deploying an opinionated Kubernetes cluster. It's used by my own Okami101 cluster. It provides :

* Complete monitoring (Kube Prometheus Stack), logging (Loki), tracing (Tempo)
* Ingress routing via Traefik (load balanced mode) and certificates managed by cert-manager
* Many types of DB, including Redis, MySQL, PostgresSQL (cluster mode), Elasticseach
* UI web managers, as Portainer, PHPMyAdmin, PgAdmin
* Complete CI solution with Gitea and Concourse, as well as custom private docker registry
* Some additional tools for my own needs (umami and redmine)

For proper install, it should be used on top of [Terraform Hcloud K0S](https://github.com/adr1enbe4udou1n/terraform-hcloud-k0s).

Give some labels after installation in order to identify node roles properly.

```sh
kubectl label nodes kube-data-01 node-role.kubernetes.io/data=true
kubectl label nodes kube-data-02 node-role.kubernetes.io/data=true
kubectl label nodes kube-monitor-01 node-role.kubernetes.io/monitor=true
kubectl label nodes kube-runner-01 node-role.kubernetes.io/runner=true
```

## Usage

### Prepare

Next you need to install some helm charts as well as CRDs.

```sh
# add csi drivers
kubectl -n kube-system create secret generic hcloud --from-literal=token=xxx
kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/v2.3.2/deploy/kubernetes/hcloud-csi.yml
kubectl patch sc hcloud-volumes -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# automatic upgrade
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.11.0/system-upgrade-controller.yaml

# install CRDs
kubectl apply --server-side --force-conflicts -k https://github.com/traefik/traefik-helm-chart/traefik/crds/

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

kubectl apply -f https://raw.githubusercontent.com/bitnami-labs/sealed-secrets/main/helm/sealed-secrets/crds/bitnami.com_sealedsecrets.yaml
```

## Grafana Dashboards

| ID    | App          |
| ----- | ------------ |
| 13032 | Longhorn     |
| 7036  | Concourse    |
| 4475  | Traefik      |
| 14055 | Loki         |
| 13502 | Minio        |
| 14191 | Elasticseach |
| 14114 | Postgresql   |
| 14057 | MySQL        |
| 10991 | RabbitMQ     |
| 763   | Reddis       |
