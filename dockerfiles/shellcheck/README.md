# shellcheck

## Build for Multi Arch

```bash

$ docker builder create --name multiarch --use colima

$ docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/ardikabs/etc/shellcheck:latest .

```
