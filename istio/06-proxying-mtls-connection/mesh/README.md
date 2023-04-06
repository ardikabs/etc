# Mutual TLS termination from Sidecar

## Requirements

1. Need to distribute necessary client certificate to all namespaces that demand the connection.
2. Need to define a namespace for Virtual Service as well as Destination Rule.
