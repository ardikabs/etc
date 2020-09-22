# Useful Command
```bash
# Get certificate-key
$ kubeadm init phase upload-certs --upload-certs 2>/dev/null | egrep -o "^[a-z0-9].+$"

# Get CA Certificate Hash
$ kubeadm token create --ttl=1s --print-join-command 2>/dev/null | egrep -o "\bsha256.+$"
```
