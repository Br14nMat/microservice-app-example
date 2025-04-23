FROM node:8.17.0 AS builder

WORKDIR /app
COPY . .

RUN npm install
RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf.template /etc/nginx/nginx.conf.template

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENV PORT=8080 \
    AUTH_API_ADDRESS=http://auth-api:8081/ \
    TODOS_API_ADDRESS=http://todos-api:8082/

ENTRYPOINT ["/entrypoint.sh"]



