FROM rancher/k3s:v1.18.17-k3s1

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"

ENV container docker

COPY entrypoint.sh /entrypoint.sh

EXPOSE 443
EXPOSE 10251

ENTRYPOINT ["/entrypoint.sh"]