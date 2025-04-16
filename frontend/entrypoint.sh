#!/bin/sh

envsubst '${AUTH_API_ADDRESS} ${TODOS_API_ADDRESS}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
