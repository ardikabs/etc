#!/bin/bash

curl -sSfL "https://github.com/bufbuild/buf/releases/download/${BUF_VERSION}/buf-Linux-x86_64" -o /usr/local/bin/buf
curl -sSfL "https://github.com/angular/clang-format/raw/${CLANG_FORMAT_VERSION}/bin/linux_x64/clang-format" -o /usr/local/bin/clang-format
curl -sSfL "https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh" | sh -s -- -b $(go env GOPATH)/bin ${GOLANGCI_LINT_VERSION}
curl -sSfL https://github.com/yoheimuta/protolint/releases/download/v${PROTOLINT_VERSION}/protolint_${PROTOLINT_VERSION}_Linux_x86_64.tar.gz | tar xzv --directory=/usr/local/bin proto*

chmod +x /usr/local/bin/{buf,clang-format}

go install github.com/vektra/mockery/v2@${MOCKERY_VERSION}
go install google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION}
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION}
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@${PROTOC_GEN_GO_GRPC_GATEWAY_VERSION}
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@${PROTOC_GEN_GRPC_OPENAPIV2_VERSION}
go install golang.org/x/tools/cmd/goimports@${GOIMPORTS_VERSION}

exec "$@"
