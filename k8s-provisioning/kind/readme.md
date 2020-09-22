# Docker network kind
```bash
docker network create \
    --driver=bridge \
    --subnet=100.64.0.0/10 \
    --ip-range=100.64.0.0/16 \
    --gateway=100.64.0.0.1 \
    kind
```

# References
[kind](https://kind.sigs.k8s.io/docs/user/quick-start/)