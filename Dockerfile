# Build stage
FROM maven:3.8.4-openjdk-17 as build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests -Dspring.profiles.active=mysql

# Run stage
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/spring-petclinic-3.3.0-SNAPSHOT.jar spring-petclinic.jar
ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]