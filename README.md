[![Github release](https://img.shields.io/github/v/release/rolfwessels/simple-gdrive-backups)](https://github.com/rolfwessels/simple-gdrive-backups/releases)
[![Dockerhub Status](https://img.shields.io/badge/dockerhub-ok-blue.svg)](https://hub.docker.com/r/rolfwessels/simple-gdrive-backups/tags)
[![Dockerhub Version](https://img.shields.io/docker/v/rolfwessels/simple-gdrive-backups?sort=semver)](https://hub.docker.com/r/rolfwessels/simple-gdrive-backups/tags)
[![GitHub](https://img.shields.io/github/license/rolfwessels/simple-gdrive-backups)](https://github.com/rolfwessels/simple-gdrive-backups/licence.md)

![simple-gdrive-backups](./docs/logo.png "simple-gdrive-backups")

# Simple-gdrive-backups

This makes simple-gdrive-backups happen

## Getting started

Open the docker environment to do all development and deployment

```bash
# bring up dev environment
make build up
# build the project ready for publish
make publish
```

## Available make commands

### Commands outside the container

- `make up` : brings up the container & attach to the default container
- `make down` : stops the container
- `make build` : builds the container
- `docker-login` : Log into docker
- `make build` : builds the container
- `make build` : builds the container

### Commands to run inside the container

- `make start` : Run the simple-gdrive-backups
- `make publish` : Build the simple-gdrive-backups to build folder
- `make deploy` : Deploy the simple-gdrive-backups

## Research

- <https://opensource.com/article/18/8/what-how-makefile> What is a Makefile and how does it work?
