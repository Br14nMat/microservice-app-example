#!/bin/sh

envsubst '$${AUTH_API_ADDRESS} $${TODOS_API_ADDRESS}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
