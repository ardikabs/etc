# etc/Dockerfiles
This is collection of Dockerfiles for my personal task. All container image here is built with [kaniko](https://github.com/GoogleContainerTools/kaniko).

## How-To run Dockerfile.terraform
```bash
export REPOSITORY=ardikabs
export TERRAFORM_VERSION=0.12.25

executor \
--context=$PWD \
--dockerfile=/path/to/Dockerfile.terraform \
--destination=${REPOSITORY}/terraform-cx:${TERRAFORM_VERSION} \
--build-arg=TERRAFORM_VERSION=${TERRAFORM_VERSION}
```

## How-To run Dockerfile.kops
```bash
export REPOSITORY=ardikabs
export KOPS_VERSION=v1.16.4
export KUBECTL_VERSION=v1.15.12
executor \
--context=$PWD \
--dockerfile=/path/to/Dockerfile.kops \
--destination=${REPOSITORY}/kops-cx:${KOPS_VERSION} \
--build-arg=KOPS_VERSION=${KOPS_VERSION}
--build-arg=KUBECTL_VERSION=${KUBECTL_VERSION}
```