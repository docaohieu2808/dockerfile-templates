# syntax=docker/dockerfile:1

## Build stage ##
FROM mcr.microsoft.com/dotnet/sdk:10.0.403-alpine3.24 AS build
WORKDIR /src

# Restore first so the NuGet layer is cached until the project file changes.
COPY App.csproj ./
RUN --mount=type=cache,target=/root/.nuget/packages dotnet restore

COPY . .
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet publish App.csproj -c Release -o /out --no-restore /p:UseAppHost=false

## Run stage ##
FROM mcr.microsoft.com/dotnet/aspnet:10.0.14-alpine3.24
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080

COPY --from=build /out ./

# The aspnet images ship a non-root "app" user (uid 1654).
USER app

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD ["wget", "-q", "--spider", "http://127.0.0.1:8080/health"]
ENTRYPOINT ["dotnet", "App.dll"]
