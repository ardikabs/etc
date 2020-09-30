FROM fluent/fluentd:v1.11
USER root
RUN apk add --no-cache --update --virtual build-dependencies \
        alpine-sdk \
        ruby-dev \
    && fluent-gem install \
        fluent-plugin-prometheus \
        fluent-plugin-multi-format-parser \
        fluent-plugin-concat \
        fluent-plugin-grok-parser \
        fluent-plugin-record-modifier \
        fluent-plugin-rewrite-tag-filter \
        fluent-plugin-json-in-json-2 \
        fluent-plugin-kubernetes_metadata_filter \
        fluent-plugin-elasticsearch \
    && apk del build-dependencies \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*