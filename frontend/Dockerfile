FROM node:8.17.0-slim as builder

WORKDIR /app

COPY package*.json ./
RUN npm install npm@6.13.4 -g && \
    npm install

COPY . .
RUN npm run build

FROM nginx:alpine

RUN apk add --no-cache gettext

RUN rm -rf /etc/nginx/conf.d/*

COPY default.conf.template /etc/nginx/conf.d/default.conf.template

COPY entrypoint.sh /entrypoint.sh


COPY --from=builder /app/dist /usr/share/nginx/html

RUN chmod +x /entrypoint.sh

ENV PORT=8080 \
    AUTH_API_ADDRESS=http://auth-api:8000 \
    TODOS_API_ADDRESS=http://todos-api:8082

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
