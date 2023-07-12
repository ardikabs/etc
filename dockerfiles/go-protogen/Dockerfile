FROM golang:1.20-alpine3.16 as builder

ENV HOME=/home
ENV GO111MODULE=on
ENV BUF_VERSION=v1.23.1
ENV PROTOC_GEN_GO_VERSION=v1.30.0
ENV PROTOC_GEN_GO_GRPC_VERSION=v1.3.0
ENV PROTOC_GEN_GO_GRPC_GATEWAY_VERSION=v2.16.0
ENV PROTOC_GEN_GRPC_OPENAPIV2_VERSION=v2.16.0
ENV MOCKERY_VERSION=v2.32.0
ENV GOLANGCI_LINT_VERSION=v1.53.3
ENV GOIMPORTS_VERSION=v0.10.0
ENV CLANG_FORMAT_VERSION=v1.6.0
ENV PROTOLINT_VERSION=0.40.0

COPY entrypoint.sh /docker-entrypoint.sh

RUN mkdir -p ${HOME}/.cache && \
    chmod 777 ${HOME}/.cache

RUN apk add build-base \
    bash \
    curl \
    git

RUN bash /docker-entrypoint.sh
CMD [ "/docker-entrypoint.sh" ]