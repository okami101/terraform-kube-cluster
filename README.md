# Usage

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

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.58.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

# grafana password
kg secret -n monitoring grafana -o yaml
```

## FluxCD

First add private key as deployment key to the repo.

```sh
flux bootstrap git --url=ssh://git@gitea.okami101.io/okami101/flux-source --branch=main --components-extra=image-reflector-controller,image-automation-controller --private-key-file=keys/id_cluster --toleration-keys=node-role.kubernetes.io/runner

# [optional] backup old sealed key if needed
kubectl get secret -n flux-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > main.key

# generate kubeseal manifests to the repo
flux create source helm sealed-secrets --interval=1h --url=https://bitnami-labs.github.io/sealed-secrets --export >> sealed-secrets.yaml
flux create helmrelease sealed-secrets --interval=1h --release-name=sealed-secrets-controller --target-namespace=flux-system --source=HelmRepository/sealed-secrets --chart=sealed-secrets --chart-version=">=2.6.0" --crds=CreateReplace --export >> sealed-secrets.yaml
# the push and all done

# [optional] restore sealed key after delete current key if needed
kubectl apply -f main.key
kubectl delete pod -n flux-system -l app.kubernetes.io/name=sealed-secrets

# get public key
kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=flux-system > pub-sealed-secrets.pem

# activate monitoring
flux create source git flux-monitoring --interval=30m --url=https://github.com/fluxcd/flux2 --branch=main --export >> flux-monitoring.yaml
flux create kustomization monitoring-config --interval=1h --prune=true --source=flux-monitoring --path="./manifests/monitoring/monitoring-config" --health-check-timeout=1m --export >> flux-monitoring.yaml
```
