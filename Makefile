.DEFAULT_GOAL := help

# General Variables
date=$(shell date +'%y.%m.%d.%H.%M')
project := Simple-gdrive-backups
container := simple-gdrive-backups
docker-filecheck := /.dockerenv
docker-warning := ""
RED=\033[0;31m
GREEN=\033[0;32m
NC=\033[0m # No Color
versionPrefix := 0.1
version := $(versionPrefix).$(shell git rev-list HEAD --count)
shorthash := $(shell git rev-parse --short=8 HEAD)
version-suffix := 
registry := public.ecr.aws/_______/simple-gdrive-backups

ifdef GITHUB_BASE_REF
	current-branch :=  $(patsubst refs/heads/%,%,${GITHUB_HEAD_REF})
else ifdef GITHUB_REF
	current-branch :=  $(patsubst refs/heads/%,%,${GITHUB_REF})
else
	current-branch :=  $(shell git rev-parse --abbrev-ref HEAD)
endif

ifeq ($(current-branch), main)
	docker-tags := -t $(registry):alpha -t $(registry):latest -t $(registry):v$(version) -t $(registry):$(shorthash)
else
	version := $(versionPrefix).$(shell git rev-list main --count).$(shell git rev-list main..HEAD --count)
	version-suffix := alpha
	docker-tags := -t $(registry):$(version-suffix) -t $(registry):$(shorthash) -t $(registry):v$(version)-$(version-suffix)
endif

# Docker Warning
ifeq ("$(wildcard $(docker-filecheck))","")
	docker-warning = "⚠️  WARNING: Can't find /.dockerenv - it's strongly recommended that you run this from within the docker container."
endif

# Targets
help:
	@echo "The following commands can be used for building & running & deploying the the $(project) container"
	@echo "---------------------------------------------------------------------------------------------"
	@echo ""
	@echo "Make options when not in container"
	@echo "   - ${GREEN}docker-login${NC} : Authenticate docker with ecr"
	@echo "   - ${GREEN}docker-build${NC} : Build the container"
	@echo "   - ${GREEN}docker-push${NC}  : Push containers to registry"
	@echo "   - up          : brings up the container & attach to the default container ($(container))"
	@echo "   - down        : stops the container"
	@echo "   - build       : (re)builds the container"
	@echo ""
	@echo "Options in the contain"
	@echo "   - ${GREEN}start${NC}  	  : Run the app in the container"
	@echo ""
	@echo ""
	@echo "Examples:"
	@echo " - Just build containers    : make docker-build"
	@echo " - Everything               : make docker-login docker-build docker-push"


docker-login: 
	@echo "Login to AWS ecr ${GREEN}$(registry)${NC}"
	@aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(registry)

docker-build:
	@echo "Building branch ${RED}$(current-branch)${NC} to ${GREEN}$(docker-tags)${NC} with ${GREEN}$(version)-$(version-suffix)${NC}"
	@cd src && docker build --build-arg VERSION=$(version) --build-arg VERSION_SUFFIX=$(version-suffix) ${docker-tags} .

docker-push:
	@echo -e "Pusing to ${GREEN}$(docker-tags)${NC}"
	@docker push --all-tags $(registry)
	@docker images | grep "$(registry)" | awk '{system("docker rmi " "'"$(registry):"'" $$2)}'

up:
	@echo "Checking for $(HOME)/.aws ..."
ifeq ("$(wildcard $(HOME)/.aws)","")
	@echo "Creating $(HOME)/.aws"
	@mkdir $(HOME)/.aws 
endif
	@echo "Starting containers..."
	@docker-compose up -d
	@echo "Attaching shell..."
	@rsync -rup --copy-links ~/.aws .
	@docker-compose exec $(container) bash

down:
	@echo "Stopping containers..."
	@docker-compose down

build:
	@echo "Building containers..."
	@docker-compose build

start: docker-check
	@printf  "Starting ${GREEN}$(project)${NC}\n"
	@cd src/simple-gdrive-backups.Api && dotnet run

docker-check:
	$(call assert-file-exists,$(docker-filecheck), This step should only be run from Docker. Please run `make up` first.)

env-check:
	$(call check_defined, env, No environment set. Supported environments are: [ dev | prod ]. Please set the env variable. e.g. `make env=dev plan`)


check_defined = \
    $(strip $(foreach 1,$1, \
    	$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
    	$(error Undefined $1$(if $2, ($2))))

define assert
  $(if $1,,$(error Assertion failed: $2))
endef

define assert-file-exists
  $(call assert,$(wildcard $1),$1 does not exist. $2)
endef
