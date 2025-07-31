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

## 🚀 Ví dụ Dockerfile theo từng framework/ngôn ngữ

### React

#### Dockerfile (npm - basic)

```dockerfile
##### Dockerfile #####
## build stage ##
FROM node:18.18-alpine as build

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

## run stage ##
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```


#### Dockerfile (npm - advanced)

```dockerfile
##### Dockerfile #####
## build stage ##
FROM node:18.18-alpine as build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

## run stage ##
FROM nginx:alpine
RUN mkdir /run
COPY --from=build /app/build /run
COPY nginx.conf /etc/nginx/nginx.conf
```


#### nginx.conf

```nginx
##### nginx.conf ####
user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
  worker_connections  1024;
}
http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
  access_log  /var/log/nginx/access.log  main;
  sendfile        on;
  keepalive_timeout  65;
  server {
    listen       80;
    server_name  webclient;
    location / {
      root   /run;
      index  index.html;
      try_files $uri $uri/ /index.html;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
      root   /usr/share/nginx/html;
    }
  }
}
```

#### Dockerfile (yarn)

```dockerfile
##### Dockerfile #####
## build stage ##
FROM node:18.18-alpine as build
WORKDIR /app
COPY . .
RUN yarn
RUN yarn build

## run stage ##
FROM nginx:alpine
RUN mkdir /run
COPY --from=build /app/build /run
COPY nginx.conf /etc/nginx/nginx.conf
```

### Vue \& Angular

```dockerfile
##### Dockerfile #####
## build stage ##
FROM node:18.18-alpine as build
WORKDIR /app
COPY . .
RUN npm install 
RUN npm run build

## run stage ##
FROM nginx:alpine
RUN mkdir /run
COPY --from=build /app/dist /run
COPY nginx.conf /etc/nginx/nginx.conf
```

> File `nginx.conf` tương tự ví dụ React ở trên.

### Nodejs

```dockerfile
##### Dockerfile #####
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
##### Dockerfile #####
FROM node:18-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN npm install
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build


FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

RUN mkdir .next
RUN chown nextjs:nodejs .next

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
```


### NestJS (npm)

```dockerfile
##### Dockerfile #####
## build stage ##
FROM node:12.19.0-alpine3.9 AS development

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install glob rimraf

RUN npm install --only=development

COPY . .

RUN npm run build

## run stage ##
FROM node:12.19.0-alpine3.9 as production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --only=production

COPY . .

COPY --from=development /usr/src/app/dist ./dist

CMD ["node", "dist/main.js"]
```

### NestJS (yarn)

```dockerfile
##### Dockerfile #####
## build stage ##
FROM node:lts as builder

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build

## run stage ##
FROM node:lts-slim

ENV NODE_ENV production
USER node

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json yarn.lock ./

RUN yarn install --production --frozen-lockfile

COPY --from=builder /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
```

### NestJS (advanced)

```dockerfile
##### Dockerfile #####
## build stage ##
FROM node:18-alpine as build

WORKDIR /app
RUN apk add --no-cache libc6-compat

ENV NODE_ENV production

RUN addgroup --system --gid 1001 node
RUN adduser --system --uid 1001 node

COPY --chown=node:node --from=dev /app/node_modules ./node_modules
COPY --chown=node:node . .

RUN yarn build

RUN yarn --frozen-lockfile --production && yarn cache clean

USER node

## run stage ##
FROM node:18-alpine as prod

WORKDIR /app
RUN apk add --no-cache libc6-compat

ENV NODE_ENV production

RUN addgroup --system --gid 1001 node
RUN adduser --system --uid 1001 node

COPY --chown=node:node --from=build /app/dist dist
COPY --chown=node:node --from=build /app/node_modules node_modules

USER node

CMD ["node", "dist/main.js"]
```

Dockerfile Java
Mình hiểu rằng với Java spring boot có rất nhiều base image phù hợp cho các loại code dự án nên mình cũng đã tổng hợp ở đây.

Những base image này mình đã dành thời gian research nhưng mọi người chỉ cần vài giây để lựa chọn từ danh sách này. Tuy hơi tốn công nhưng cũng chỉ mong sao mọi người sử dụng thuận tiện nhất:

adoptopenjdk/openjdk15:alpine-jre
openjdk:17-alpine
openjdk:17.0.1-jdk-slim
openjdk:17.0.2-jdk
eclipse-temurin:8-jre-alpine
eclipse-temurin:17_35-jdk-alpine
eclipse-temurin:11-jre-alpine
eclipse-temurin:17-jre-alpine
eclipse-temurin:17.0.8.1_1-jre-ubi9-minimal
eclipse-temurin:17-jre-jammy
eclipse-temurin:17.0.8.1_1-jre-focal
eclipse-temurin:17.0.8.1_1-jre-alpine
eclipse-temurin:21-jre-alpine
amazoncorretto:17.0.0-alpine
amazoncorretto:8u382-al2023

### Java Spring Boot Maven (basic)

> Chọn base image phù hợp:
> `eclipse-temurin:17-jre-alpine`, `amazoncorretto:17.0.0-alpine`, `openjdk:17-alpine`, ...

```dockerfile
##### Dockerfile #####
FROM maven:3.8.3-openjdk-17 as build
WORKDIR ./src
COPY . .
RUN mvn install -DskipTests=true

FROM eclipse-temurin:17.0.8.1_1-jre-ubi9-minimal ## thay tương ứng các image đề xuất ở trên nếu không chạy

RUN unlink /etc/localtime;ln -s  /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
COPY --from=build src/target/filename.jar /run/filename.jar

EXPOSE 8888

ENV JAVA_OPTIONS="-Xmx2048m -Xms256m"
ENTRYPOINT java -jar $JAVA_OPTIONS /run/filename.jar
```

### .NET Core
Hãy luôn chú ý bạn phải xác định được dự án bạn đang chạy .NET nào và chỉ cần chỉnh sửa cho phù hợp là được nhé.

```dockerfile
##### Dockerfile ##### 
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
##### Dockerfile ##### 
FROM php:8.0-fpm AS build

WORKDIR /var/www
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions mbstring pdo_mysql zip exif pcntl gd memcached

RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    git \
    curl \
    lua-zlib-dev \
    libmemcached-dev \
    nginx \
    nano

RUN apt-get install -y supervisor

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 www && useradd -u 1000 -ms /bin/bash -g www www

COPY --chown=www:www-data . /var/www

RUN chmod -R ug+w /var/www/storage

RUN cp docker/supervisor.conf /etc/supervisord.conf
RUN cp docker/php.ini /usr/local/etc/php/conf.d/app.ini
RUN cp docker/nginx.conf /etc/nginx/sites-enabled/default

RUN mkdir -p /var/log/php && touch /var/log/php/errors.log && chmod 777 /var/log/php/errors.log


RUN cp docker/.env.production .env

RUN composer install --ignore-platform-reqs --optimize-autoloader --no-dev

RUN chmod +x /var/www/docker/run.sh


EXPOSE 80

ENTRYPOINT ["/var/www/docker/run.sh"]
# CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
```


### Python

#### Django

```dockerfile
##### Dockerfile ##### 
ROM python:3.10-slim-buster

WORKDIR /app
ENV DJANGO_SETTINGS_MODULE=sample_backend.settings.production
ENV DATABASE_HOST='mysql'

RUN pip install -U pip
# RUN apt-get update
# RUN apt-get install -y python3-pip cron nano build-essential python3-dev default-libmysqlclient-dev  default-mysql-client  ffmpeg
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
   --mount=target=/var/cache/apt,type=cache,sharing=locked \
   rm -f /etc/apt/apt.conf.d/docker-clean \
   && apt-get update \
   && apt-get -y --no-install-recommends install \
   python3-pip cron nano build-essential python3-dev default-libmysqlclient-dev  default-mysql-client  ffmpeg libmagic1


COPY ./requirements.txt /app
RUN pip3 install -r requirements.txt

COPY ./ .

COPY docker_entrypoint.sh app.sh

## Run Stage ##
EXPOSE 8000

CMD uwsgi --http 0.0.0.0:8000 \
   --thunder-lock \
   --single-interpreter \
   --enable-threads \
   --processes=${UWSGI_WORKERS:-2} \
   --buffer-size=8192 \
   # --chdir /app/ \
   # --wsgi-file talent.wsgi.py \
   --module sample_backend.wsgi --py-autoreload 1
```


#### Flask

```dockerfile
##### Dockerfile #####
FROM python:3.10-slim-buster

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD [ "python3", "-m" , "flask", "run" ]
```


### Golang

```dockerfile
## Build Stage ##
# First pull Golang image
FROM golang:1.17-alpine as build-env
 
ENV APP_NAME sample-dockerize-app
ENV CMD_PATH main.go
 
COPY . $GOPATH/src/$APP_NAME
WORKDIR $GOPATH/src/$APP_NAME
 
# Budild application
RUN CGO_ENABLED=0 go build -v -o /$APP_NAME $GOPATH/src/$APP_NAME/$CMD_PATH
 
## Run Stage ##
FROM alpine:3.14
 
ENV APP_NAME sample-dockerize-app
COPY --from=build-env /$APP_NAME .
 
EXPOSE 8081
 
CMD ./$APP_NAME
```


### Rust

```dockerfile
##### Dockerfile ##### 
## Builder Stage ##
FROM rust:1.68.2-slim as builder

WORKDIR /usr/src/app
RUN apt-get update && apt-get install musl-tools --no-install-recommends -y
RUN rustup target add x86_64-unknown-linux-musl
COPY Cargo.toml ./

RUN mkdir src/ && echo "fn main() {println!(\"if you see this, the build broke\")}" > src/main.rs && \
  cargo build --target x86_64-unknown-linux-musl --release && \
  rm -f target/x86_64-unknown-linux-musl/release/deps/eldevops*

COPY . ./

RUN cargo build --target x86_64-unknown-linux-musl --release

## Run stage ##
FROM alpine:3.17 as runtime
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/eldevops/usr/local/bin

ENTRYPOINT ["/usr/local/bin/eldevops"]
```


### Ruby on Rails

```dockerfile
##### Dockerfile ##### 
FROM ruby:2.5.9-alpine AS builder
RUN apk add \
    build-base \
    postgresql-dev
COPY Gemfile* .
RUN bundle install

FROM ruby:2.5.9-alpine AS runner
RUN apk add \
    tzdata \
    nodejs \
    postgresql-dev
WORKDIR /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
```


### Swift

```dockerfile
##### Dockerfile ##### 
FROM swift:5.5
WORKDIR /app
COPY . .

RUN apt-get update && apt-get install libsqlite3-dev
RUN swift package clean
RUN swift build
RUN mkdir /app/bin
RUN mv `swift build --show-bin-path` /app/bin

EXPOSE 8080
ENTRYPOINT ./bin/debug/Run serve --env local --hostname 0.0.0.0
```

### Swift (advanced)

```dockerfile
##### Dockerfile #####
## Builder Stage ##
FROM swift:5.8-jammy as build
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
&& apt-get -q update \
&& apt-get -q dist-upgrade -y\
&& rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve

COPY . .

RUN swift build -c release --static-swift-stdlib

WORKDIR /staging

RUN cp "$(swift build --package-path /build -c release --show-bin-path)/App" ./

RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

## Run stage ##
FROM ubuntu:jammy

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
&& apt-get -q update \
&& apt-get -q dist-upgrade -y \
&& apt-get -q install -y \
ca-certificates \
tzdata \

&& rm -r /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

COPY --from=build --chown=vapor:vapor /staging /app

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
```

### C++

```dockerfile
##### Dockerfile ##### 
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
##### Dockerfile ##### 
## Builder Stage ##
FROM dart AS build
WORKDIR /app
COPY pubspec.* /app/
RUN dart pub get --no-precompile
COPY app.dart /app/
RUN dart compile exe app.dart -o app

## Run stage ##
FROM debian:stable-slim
COPY --from=build /app/app /app/app
CMD ["/app/app"]
```
