#!/bin/sh

wget http://nginx.org/download/nginx-$(nginx -v 2>&1 | cut -d '/' -f 2).tar.gz
tar -xzvf nginx-*.tar.gz

git clone https://github.com/vozlt/nginx-module-sts.git
git clone https://github.com/vozlt/nginx-module-stream-sts.git

cd nginx-*

./configure --with-stream --with-compat --add-dynamic-module=../nginx-module-sts/ --add-dynamic-module=../nginx-module-stream-sts/

make modules

mv objs/ngx_http_stream_server_traffic_status_module.so /build
mv objs/ngx_stream_server_traffic_status_module.so /build
