# kubexec

All-in-one image for Kubernetes related operations. The following tools installed by default:

* Kubectl v1.27.1
* Kustomize v4.4.1
* Helm v3.12.0
* Helmfile v0.154.0
* Mozilla/SOPS v3.7.3

Also included with the following `helm` plugins:

* `helm-diff` v3.8.0
* `helm-push` v0.10.3
* `helm-unittest` v0.2.3
* `helm-docs` v1.11.0

You can also able to override version of the pre-installed tools, by triggering the `/docker-entrypoint.sh` followed with environment variable belows:

```bash
export HELM_VERSION=v3.12.0
export KUBECTL_VERSION=v1.27.1
export KUSTOMIZE_VERSION=v4.4.1
export SOPS_VERSION=v3.7.3
export HELMFILE_VERSION=0.154.0
export HELM_PLUGIN_DIFF_VERSION=3.8.0
export HELM_PLUGIN_PUSH_VERSION=0.10.3
export HELM_PLUGIN_UNITTEST_VERSION=0.2.3
```

## Status

Active, [ghcr.io/ardikabs/etc/kubeexec](https://github.com/ardikabs/etc/pkgs/container/etc%2Fkubexec)