FROM nginx:stable-alpine3.23 AS build

RUN apk add --no-cache \
    build-base \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    gettext-dev \
    git \
    gd-dev \
    git

WORKDIR /build
COPY install.sh ./
RUN sh install.sh

FROM nginx:stable-alpine3.23

COPY --from=build /build/ngx_http_stream_server_traffic_status_module.so /usr/lib/nginx/modules
COPY --from=build /build/ngx_stream_server_traffic_status_module.so /usr/lib/nginx/modules

