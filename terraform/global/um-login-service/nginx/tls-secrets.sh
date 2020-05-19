#!/bin/sh

if [ ! -f dhparam.pem ]; then
    openssl dhparam -out dhparam.pem 2048
fi

# if [ ! -f ingress.crt ]; then
#     kubectl get secret gluu -o json \
#     | grep '\"ssl_cert' \
#     | awk -F '"' '{print $4}' \
#     | base64 --decode > ingress.crt
# fi

# if [ ! -f ingress.key ]; then
#     kubectl get secret gluu -o json \
#     | grep '\"ssl_key' \
#     | awk -F '"' '{print $4}' \
#     | base64 --decode > ingress.key
# fi
