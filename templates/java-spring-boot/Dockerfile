# syntax=docker/dockerfile:1

## Build stage ##
FROM maven:3.9.16-eclipse-temurin-25-alpine AS build
WORKDIR /src

# Resolve dependencies before copying sources so this layer is cached until pom.xml changes.
COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 mvn -B -q dependency:go-offline

COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B -q package -DskipTests

## Run stage ##
FROM eclipse-temurin:27-jre-alpine-3.24

RUN addgroup -S -g 10001 app && adduser -S -u 10001 -G app app
WORKDIR /app
COPY --from=build --chown=app:app /src/target/app.jar ./app.jar

USER app

# JAVA_TOOL_OPTIONS is read by the JVM itself, so options always come before -jar
# and the exec-form ENTRYPOINT keeps java as PID 1 (it receives SIGTERM).
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -Duser.timezone=Asia/Ho_Chi_Minh"

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD ["wget", "-q", "--spider", "http://127.0.0.1:8080/health"]
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
