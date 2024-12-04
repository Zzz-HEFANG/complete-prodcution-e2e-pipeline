From maven:3.9.0-eclipse-temurin-17 as build
WORKDIR /app
COPY . .
RUN mvn clean install


FROM eclipse-temurin:17-jdk-focal
WORKDIR /app
COPY target/demoapp.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]