FROM ghcr.io/ardikabs/etc/shell

ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /mock

COPY config.yml healthz.imp.json ./

RUN mkdir -p /usr/local/bin && \
    curl -sSfL "https://github.com/friendsofgo/killgrave/releases/download/v0.5.0/killgrave_0.5.0_linux_x86_64.tar.gz" -o - | tar -xz --directory=/usr/local/bin killgrave

CMD ["/usr/local/bin/killgrave", "--config", "/mock/config.yml"]