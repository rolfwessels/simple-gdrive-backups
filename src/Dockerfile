FROM mcr.microsoft.com/dotnet/sdk:7.0-alpine AS build-env
WORKDIR /app


COPY simple-gdrive-backups.Api/*.csproj ./simple-gdrive-backups.Api/


WORKDIR /app/simple-gdrive-backups.Api
RUN dotnet restore
WORKDIR /app
COPY ./ ./
WORKDIR /app/simple-gdrive-backups.Api
ARG  VERSION=0.0.0
ARG  VERSION_SUFFIX=pre-alpha
RUN dotnet publish  -p:VersionSuffix=${VERSION_SUFFIX}  -p:FileVersion=${VERSION} -p:VersionPrefix=${VERSION} -c Release -o out


# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine

WORKDIR /app
COPY --from=build-env /app/simple-gdrive-backups.Api/out .
RUN apk add --no-cache \
        python3 \
        py3-pip \
        curl \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
        awscli \
    && rm -rf /var/cache/apk/*
HEALTHCHECK CMD curl --fail http://localhost:5298/api/ping/hc || exit 1

ARG  VERSION=0.0.0
ARG  VERSION_SUFFIX=pre-alpha

LABEL dva-version="${VERSION}"
LABEL dva-version-suffix="${VERSION_SUFFIX}"
LABEL dva-maintainer="Rolf Wessels"

EXPOSE 5298/tcp
CMD ["dotnet", "simple-gdrive-backups.Api.dll"]
