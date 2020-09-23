FROM fluent/fluentd:v1.11
USER root
RUN apk --no-cache --update add alpine-sdk ruby-dev \
    && fluent-gem install \
        fluent-plugin-multi-format-parser \
        fluent-plugin-concat \
        fluent-plugin-grok-parser \
        fluent-plugin-record-modifier \
        fluent-plugin-rewrite-tag-filter \
        fluent-plugin-json-in-json-2 \
        fluent-plugin-kubernetes_metadata_filter \
        fluent-plugin-s3 \
    && apk del alpine-sdk ruby-dev \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*