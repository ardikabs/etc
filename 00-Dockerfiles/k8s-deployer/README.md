# helmfile-kustomize

Build the `helmfile-kustomize` container image
```bash
$ docker build -t ardikabs/helmfile-kustomize:3.1.1 \
    --build-arg HELM_VERSION=v3.1.1 \
    --build-arg KUBECTL_VERSION=v1.16.10 \
    --build-arg HELMFILE_VERSION=v0.130.0 \
    --build-arg KUSTOMIZE_VERSION=v3.8.4 \
    -f Dockerfile .
```