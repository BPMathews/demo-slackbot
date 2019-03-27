MAKEFLAGS += --silent

ENV_FILE := dev.env
-include ${ENV_FILE}
export

# Environment Vars
PWD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_PATH := $(shell sed -n 's/^module //p' $(PWD)/go.mod)
PROJECT_NAME := $(shell basename $(PROJECT_PATH))
PROJECT_SOURCE = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
GOBIN := ${GOPATH}/bin
GOCACHE := /tmp/gocache

# Build Vars
BUILD_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BUILD_TIME := $(shell date)
BUILD_VERSION := $(shell git describe --always --dirty)

# Docker Vars
DOCKER_NETWORK_NAME := slackbot-network
DOCKER_IMAGE := $(PROJECT_NAME):$(BUILD_BRANCH)
DOCKER_BUILD_IMAGE := $(PROJECT_NAME)-build:build

# Linker Flags
LINKER_FLAGS := -X '\''$(PROJECT_PATH)/env.version=$(BUILD_VERSION)'\''
LINKER_FLAGS += -X '\''$(PROJECT_PATH)/env.branch=$(BUILD_BRANCH)'\''
LINKER_FLAGS += -X '\''$(PROJECT_PATH)/env.buildTime=$(BUILD_TIME)'\''

all: help

## build: Build the application.
build: ${PROJECT_NAME}

## clean: Remove all build atrifacts and generated files.
clean:
	rm -f ${PROJECT_NAME}
	go clean -x

## docker: Build a application in container.
docker:
	docker build -t $(DOCKER_BUILD_IMAGE) -f docker/Dockerfile.build .
	docker run --rm -v "$(PWD)":/go/src/$(PROJECT_PATH) -w /go/src/$(PROJECT_PATH) $(DOCKER_BUILD_IMAGE) sh -c 'make build'
	docker build -t $(DOCKER_IMAGE) -f docker/Dockerfile .

## run-docker: Build and run the application on the local Docker server.
run-docker: docker
	echo "Starting '${PROJECT_NAME}' in Docker..."
	docker run --rm --env-file $(ENV_FILE) -p 8080:8080 $(DOCKER_IMAGE)

## help: Print out a list of available build targets.
help:
	echo "Make targets available for '${PROJECT_NAME}'"
	echo
	sed -n 's/^##//p' ${PWD}/Makefile | column -t -s ':' | sed -e 's/^/ /'
	echo

## run: Start the application.
run: build
	./${PROJECT_NAME}

## test: Test the application.
test: build
	echo "Testing '${PROJECT_NAME}'..."
	go test ./... -coverprofile=unit-test-coverage.out
	go tool cover -html=unit-test-coverage.out
	echo

${PROJECT_NAME}: Makefile go.mod ${PROJECT_SOURCE}
	echo "Building '${PROJECT_NAME}'..."
	go fmt ./...
	go vet ./...
	go build -ldflags='$(LINKER_FLAGS)' -v -o ${PROJECT_NAME}
	echo

# Demo Targets
deep-clean: clean
	rm -rf ${GOBIN}/gocov

.PHONY: build clean deep-clean docker run-docker help run test vet
