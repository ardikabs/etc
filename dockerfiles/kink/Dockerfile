FROM rancher/k3s:v1.16.15-k3s1

ENV container docker

COPY entrypoint.sh /entrypoint.sh

EXPOSE 443
EXPOSE 10251

ENTRYPOINT ["/entrypoint.sh"]