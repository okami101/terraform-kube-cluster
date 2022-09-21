# Terraform Kube Okami

This Terraform project is intended to be used as a template for deploying an opinionated Kubernetes cluster. It's used by my own Okami101 cluster. It provides :

* Complete monitoring (Kube Prometheus Stack), logging (Loki), tracing (Jaeger)
* Ingress routing via Traefik (load balanced mode) and certificates managed by cert-manager
* Many types of DB, including Redis, MySQL, PostgresSQL (cluster mode), Elasticseach
* UI web managers, as Portainer, PHPMyAdmin, PgAdmin
* Self-hosted S3 with Minio and some DB backup cronjobs
* Complete CI solution with Gitea and Concourse, as well as custom private docker registry
* Some additional tools for my own needs (matomo and redmine)

For proper install, it should be used on top of [Terraform Hcloud K0S](https://github.com/adr1enbe4udou1n/terraform-hcloud-k0s).

## Usage

### Prepare

You firstly need a working NFS serveur into nfs_server:nfs_path address. Test it with `sudo mount -t nfs nfs_server:nfs_path nfs-test` on some worker.

Next you need to install some helm charts as well as CRDs.

```sh
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm repo add traefik https://helm.traefik.io/traefik
helm repo add portainer https://portainer.github.io/k8s
helm repo add jetstack https://charts.jetstack.io
helm repo add cert-manager-webhook-hetzner https://vadimkim.github.io/cert-manager-webhook-hetzner
helm repo add openebs https://openebs.github.io/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo add minio https://charts.min.io/
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo add concourse https://concourse-charts.storage.googleapis.com/

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml

kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.8/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.8/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.59.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

kubectl apply -f https://raw.githubusercontent.com/bitnami-labs/sealed-secrets/main/helm/sealed-secrets/crds/bitnami.com_sealedsecrets.yaml
```

### Deploy

Prepare all variables from `vars.tf`, then :

```sh
terraform init
terraform apply
```

## FluxCD

CD solution is not included in this project, I prefer to install it via the dedicated CLI, as the Terraform version is really too much cumbersome for my taste.

Firstly, add the deployment key to the target repo (`keys/id_cluster.pub` for next case). Then :

```sh
# bootstrap fluxcd
flux bootstrap git --url=ssh://git@gitea.okami101.io/okami101/flux-source --branch=main --components-extra=image-reflector-controller,image-automation-controller --private-key-file=keys/id_cluster --toleration-keys=node-role.kubernetes.io/runner

# [optional] backup old sealed key if needed
kubectl get secret -n flux-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > main.key

# clone the above repo locally
git clone git@gitea.okami101.io/okami101/flux-source.git

# generate kubeseal manifests to the repo
flux create source helm sealed-secrets --interval=1h --url=https://bitnami-labs.github.io/sealed-secrets --export >> sealed-secrets.yaml
flux create helmrelease sealed-secrets --interval=1h --release-name=sealed-secrets-controller --target-namespace=flux-system --source=HelmRepository/sealed-secrets --chart=sealed-secrets --chart-version=">=2.6.0" --crds=CreateReplace --export >> sealed-secrets.yaml

# commit, push the repo and check reconcile

# [optional] restore sealed key after delete current key if needed
kubectl apply -f main.key
kubectl delete pod -n flux-system -l app.kubernetes.io/name=sealed-secrets

# get public key
kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=flux-system > pub-sealed-secrets.pem

# activate monitoring
flux create source git flux-monitoring --interval=30m --url=https://github.com/fluxcd/flux2 --branch=main --export >> flux-monitoring.yaml
flux create kustomization monitoring-config --interval=1h --prune=true --source=flux-monitoring --path="./manifests/monitoring/monitoring-config" --health-check-timeout=1m --export >> flux-monitoring.yaml

# commit, push the repo and check reconcile
```

## Backup

```sh
gsutil mb gs://okami101-k3s-backup/
gcloud config list

gcloud iam service-accounts create velero --display-name "Velero service account"
gcloud iam service-accounts list

gcloud iam roles create velero.server --project okami101 --title "Velero Server" --permissions compute.disks.get,compute.disks.create,compute.disks.createSnapshot,compute.snapshots.get,compute.snapshots.create,compute.snapshots.useReadOnly,compute.snapshots.delete,compute.zones.get,storage.objects.create,storage.objects.delete,storage.objects.get,storage.objects.list

gcloud projects add-iam-policy-binding okami101 --member serviceAccount:velero@okami101.iam.gserviceaccount.com --role projects/okami101/roles/velero.server

gsutil iam ch serviceAccount:velero@okami101.iam.gserviceaccount.com:objectAdmin gs://okami101-k3s-backup

gcloud iam service-accounts keys create credentials-velero --iam-account velero@okami101.iam.gserviceaccount.com

velero install --use-restic --provider gcp --bucket okami101-k3s-backup --plugins velero/velero-plugin-for-gcp:v1.5.0 --secret-file ./credentials-velero
```
