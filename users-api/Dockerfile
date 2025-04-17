FROM maven:3.8.4-openjdk-8-slim AS builder
WORKDIR /app
COPY . .

RUN mvn clean install

FROM openjdk:8-jre-slim
WORKDIR /app


COPY --from=builder /app/target/users-api-0.0.1-SNAPSHOT.jar /app/users-api.jar

ENV JWT_SECRET=PRFT \
    SERVER_PORT=8083 

EXPOSE 8083

CMD ["java", "-jar", "/app/users-api.jar"]