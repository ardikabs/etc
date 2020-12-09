# k0s
```bash

# installation
curl -sSLf get.k0s.sh | sudo sh

# Controller token to be added in controller node /etc/default/k0s
CONTROLLER_TOKEN=$(k0s token create --role=controller)

k0s server $CONTROLLER_TOKEN

# Worker token to be added in worker node /etc/default/k0s
TOKEN=$(k0s token create --role=worker)

k0s worker $TOKEN

# Create user
user="developer-1"
k0s user create --groups "developer" "${user}" > ~/user.kubeconfig

kubectl create clusterrolebinding k0s-user-access --clusterrole=cluster-admin --user="developer-1"
kubectl create clusterrolebinding k0s-user-access --clusterrole=cluster-admin --group="developer"


# k0s flags

/var/lib/k0s/bin/kube-apiserver
    --requestheader-allowed-names=front-proxy-client
    --proxy-client-cert-file=/var/lib/k0s/pki/front-proxy-client.crt
    --tls-cert-file=/var/lib/k0s/pki/server.crt
    --secure-port=6443
    --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    --advertise-address=10.0.41.215
    --kubelet-client-key=/var/lib/k0s/pki/apiserver-kubelet-client.key
    --v=1
    --enable-admission-plugins=NodeRestriction
    --service-account-signing-key-file=/var/lib/k0s/pki/sa.key
    --authorization-mode=Node,RBAC
    --requestheader-client-ca-file=/var/lib/k0s/pki/front-proxy-ca.crt
    --service-cluster-ip-range=10.96.0.0/12
    --tls-private-key-file=/var/lib/k0s/pki/server.key
    --requestheader-group-headers=X-Remote-Group
    --profiling=false
    --proxy-client-key-file=/var/lib/k0s/pki/front-proxy-client.key
    --allow-privileged=true
    --requestheader-username-headers=X-Remote-User
    --client-ca-file=/var/lib/k0s/pki/ca.crt
    --kubelet-client-certificate=/var/lib/k0s/pki/apiserver-kubelet-client.crt
    --insecure-port=0
    --requestheader-extra-headers-prefix=X-Remote-Extra-
    --enable-bootstrap-token-auth=true
    --api-audiences=system:konnectivity-server
    --egress-selector-config-file=/var/lib/k0s/konnectivity.conf
    --service-account-issuer=api
    --service-account-key-file=/var/lib/k0s/pki/sa.pub
    --etcd-servers=https://127.0.0.1:2379
    --etcd-cafile=/var/lib/k0s/pki/etcd/ca.crt
    --etcd-certfile=/var/lib/k0s/pki/apiserver-etcd-client.crt
    --etcd-keyfile=/var/lib/k0s/pki/apiserver-etcd-client.key

/var/lib/k0s/bin/konnectivity-server
    --uds-name=/var/lib/k0s/run/konnectivity-server/konnectivity-server.sock
    --cluster-cert=/var/lib/k0s/pki/server.crt
    --cluster-key=/var/lib/k0s/pki/server.key
    --kubeconfig=/var/lib/k0s/pki/konnectivity.conf
    --mode=grpc
    --server-port=0
    --agent-port=8132
    --admin-port=8133
    --agent-namespace=kube-system
    --agent-service-account=konnectivity-agent
    --authentication-audience=system:konnectivity-server
    --logtostderr=true
    --stderrthreshold=1
    -v=2
    --v=1
    --enable-profiling=false

/var/lib/k0s/bin/kubelet
    --root-dir=/var/lib/k0s/kubelet
    --volume-plugin-dir=/usr/libexec/k0s/kubelet-plugins/volume/exec
    --config=/var/lib/k0s/kubelet-config.yaml
    --bootstrap-kubeconfig=/var/lib/k0s/kubelet-bootstrap.conf
    --kubeconfig=/var/lib/k0s/kubelet.conf
    --v=1
    --resolv-conf=/run/systemd/resolve/resolv.conf
    --kube-reserved-cgroup=system.slice
    --runtime-cgroups=/system.slice/containerd.service
    --kubelet-cgroups=/system.slice/containerd.service
    --container-runtime=remote
    --container-runtime-endpoint=unix:///var/lib/k0s/run/containerd.sock
```