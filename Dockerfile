# =========================
# 1) Build stage
# =========================
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /app

COPY gradlew ./
COPY gradle gradle
COPY build.gradle settings.gradle ./
# If using Maven:
# COPY pom.xml ./

RUN chmod +x gradlew

RUN ./gradlew dependencies --no-daemon
# Maven:
# RUN mvn -B dependency:resolve

COPY src src

RUN ./gradlew bootJar --no-daemon
# Maven:
# RUN mvn -B package -DskipTests

# =========================
# 2) Runtime stage
# =========================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=build /app/build/libs/*.jar app.jar
# Maven:
# COPY --from=build /app/target/*.jar app.jar

# Gateway usually runs on 8080 inside container
EXPOSE 8080

ENTRYPOINT ["java", "-Xms256m", "-Xmx512m", "-jar", "/app/app.jar"]
