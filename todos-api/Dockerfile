FROM node:8.17

WORKDIR /app

RUN npm install -g npm@6.13.4

COPY package*.json ./

RUN npm install

COPY . .

ENV TODO_API_PORT=8082 \
    JWT_SECRET=PRFT \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_CHANNEL=log_channel

EXPOSE 8082

CMD ["npm", "start"]