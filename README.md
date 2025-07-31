# 📦 Bộ Sưu Tập Dockerfile Cho Nhiều Framework \& Ngôn Ngữ

Repo này tổng hợp **Dockerfile mẫu** và các cấu hình cần thiết cho những framework, ngôn ngữ phổ biến: **React, Vue, Angular, Next.js, Node.js, NestJS, Java (Spring Boot), .NET, Laravel, Python, Golang, Rust, Ruby on Rails, Swift, C++ và Dart**.

Bạn có thể dễ dàng tham khảo, copy, chỉnh sửa để phục vụ dự án của mình!

## 📂 Danh mục

- [React (npm \& yarn)](#react)
- [Vue \& Angular](#vue--angular)
- [Nodejs](#nodejs)
- [Next.js](#nextjs)
- [NestJS (npm \& yarn)](#nestjs)
- [Java Spring Boot](#java-spring-boot)
- [.NET Core](#net-core)
- [Laravel (PHP)](#laravel)
- [Python (Django, Flask)](#python)
- [Golang](#golang)
- [Rust](#rust)
- [Ruby on Rails](#ruby-on-rails)
- [Swift (Server)](#swift)
- [C++](#c)
- [Dart](#dart)


## 📋 Hướng dẫn tổ chức repo

**Quy tắc đặt tên file:**


| Loại file | Đề xuất |
| :-- | :-- |
| Dockerfile | `Dockerfile` (không đuôi) |
| Cấu hình Nginx | `.conf` (ví dụ: `nginx.conf`) |
| Shell script | `.sh` |
| Python requirements | `requirements.txt` |
| Tài liệu tổng hợp | `.md` (ví dụ: `README.md`) |

> Tham khảo chi tiết giải thích bên dưới hoặc xem phần [FAQ](#faq).

## 🚀 Ví dụ Dockerfile theo từng framework/ngôn ngữ

### React

#### Dockerfile (npm - basic)

```dockerfile
FROM node:18.18-alpine as build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```


#### Dockerfile (npm - advanced)

```dockerfile
FROM node:18.18-alpine as build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM nginx:alpine
RUN mkdir /run
COPY --from=build /app/build /run
COPY nginx.conf /etc/nginx/nginx.conf
```


#### nginx.conf

```nginx
user  nginx;
worker_processes  1;
events { worker_connections  1024; }
http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  server {
    listen 80;
    server_name webclient;
    location / {
      root /run;
      index index.html;
      try_files $uri $uri/ /index.html;
    }
  }
}
```


### Vue \& Angular

```dockerfile
FROM node:18.18-alpine as build
WORKDIR /app
COPY . .
RUN npm install 
RUN npm run build

FROM nginx:alpine
RUN mkdir /run
COPY --from=build /app/dist /run
COPY nginx.conf /etc/nginx/nginx.conf
```

> File `nginx.conf` tương tự ví dụ React ở trên.

### Nodejs

```dockerfile
FROM node:10-alpine

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./
USER node
RUN npm install
COPY --chown=node:node . .

EXPOSE 8080
CMD [ "node", "app.js" ]
```


### NextJS

```dockerfile
FROM node:18-alpine AS base
# (Tham khảo file đầy đủ trong repo)
```


### NestJS (npm/yarn)

```dockerfile
FROM node:lts as builder
WORKDIR /usr/src/app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

FROM node:lts-slim
ENV NODE_ENV production
USER node
WORKDIR /usr/src/app
COPY package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile
COPY --from=builder /usr/src/app/dist ./dist
CMD [ "node", "dist/main.js" ]
```


### Java Spring Boot

> Chọn base image phù hợp:
> `eclipse-temurin:17-jre-alpine`, `amazoncorretto:17.0.0-alpine`, `openjdk:17-alpine`, ...

```dockerfile
FROM maven:3.8.3-openjdk-17 as build
WORKDIR ./src
COPY . .
RUN mvn install -DskipTests=true

FROM eclipse-temurin:17-jre-alpine
COPY --from=build src/target/filename.jar /run/filename.jar
EXPOSE 8888
ENV JAVA_OPTIONS="-Xmx2048m -Xms256m"
ENTRYPOINT java -jar $JAVA_OPTIONS /run/filename.jar
```


### .NET Core

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["BE.csproj", "."]
RUN dotnet restore "./BE.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "BE.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BE.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BE.dll"]
```


### Laravel (PHP)

```dockerfile
FROM php:8.0-fpm AS build
WORKDIR /var/www
# (Xem nội dung file đầy đủ trong repo)
COPY --chown=www:www-data . /var/www
RUN composer install --ignore-platform-reqs --optimize-autoloader --no-dev
...
```


### Python

#### Django

```dockerfile
FROM python:3.10-slim-buster
WORKDIR /app
COPY ./requirements.txt /app
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD uwsgi --http 0.0.0.0:8000  --module sample_backend.wsgi --py-autoreload 1
```


#### Flask

```dockerfile
FROM python:3.10-slim-buster
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
CMD [ "python3", "-m" , "flask", "run" ]
```


### Golang

```dockerfile
FROM golang:1.17-alpine as build-env
ENV APP_NAME sample-dockerize-app
COPY . $GOPATH/src/$APP_NAME
WORKDIR $GOPATH/src/$APP_NAME
RUN CGO_ENABLED=0 go build -v -o /$APP_NAME main.go

FROM alpine:3.14
COPY --from=build-env /$APP_NAME .
EXPOSE 8081
CMD ./$APP_NAME
```


### Rust

```dockerfile
FROM rust:1.68.2-slim as builder
WORKDIR /usr/src/app
COPY Cargo.toml ./
COPY . ./
RUN cargo build --release
FROM alpine:3.17 as runtime
COPY --from=builder /usr/src/app/target/release/eldevops /usr/local/bin
ENTRYPOINT ["/usr/local/bin/eldevops"]
```


### Ruby on Rails

```dockerfile
FROM ruby:2.5.9-alpine AS builder
RUN apk add build-base postgresql-dev
COPY Gemfile* .
RUN bundle install
FROM ruby:2.5.9-alpine AS runner
WORKDIR /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
```


### Swift

```dockerfile
FROM swift:5.5
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install libsqlite3-dev
RUN swift build
EXPOSE 8080
ENTRYPOINT ./bin/debug/Run serve --env local --hostname 0.0.0.0
```


### C++

```dockerfile
FROM gcc:12.2.0 AS build
COPY . /opt/test
WORKDIR /opt/test
RUN g++ -o app app.cpp

FROM ubuntu:bionic
WORKDIR /opt/test
COPY --from=build /opt/test ./
CMD ["./app"]
```


### Dart

```dockerfile
FROM dart AS build
WORKDIR /app
COPY pubspec.* /app/
RUN dart pub get --no-precompile
COPY app.dart /app/
RUN dart compile exe app.dart -o app

FROM debian:stable-slim
COPY --from=build /app/app /app/app
CMD ["/app/app"]
```
