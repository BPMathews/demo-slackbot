MAKEFLAGS += --silent

ENV_FILE := dev.env
-include ${ENV_FILE}
export

# Environment Vars
PROJECT_PATH := $(shell git config --get remote.origin.url | sed -e 's/.git//; s/git@//; s/:/\//')
PROJECT_NAME := $(shell basename $(PROJECT_PATH))
PROJECT_SOURCE = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
GOBIN := ${GOPATH}/bin
GOCACHE := /tmp/gocache
PWD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Build Vars
BUILD_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BUILD_TIME := $(shell date)
BUILD_VERSION := $(shell git describe --always --dirty)

# Docker Vars
DOCKER_IMAGE := $(PROJECT_NAME):$(BUILD_BRANCH)

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
	rm -rf vendor
	rm -f Gopkg.lock
	go clean -x

docker:
	echo ${DOCKER_IMAGE}

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

# Non-User make targets
vendor: ${GOBIN}/dep Gopkg.toml
	echo "Pulling dependencies..."
	dep ensure -v
	echo

${GOBIN}/dep:
	echo "Installing 'Dep'"
	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
	echo

${PROJECT_NAME}: Makefile vendor ${PROJECT_SOURCE}
	echo "Building '${PROJECT_NAME}'..."
	go fmt ./...
	go vet ./...
	go build -ldflags='$(LINKER_FLAGS)' -v -o ${PROJECT_NAME}
	echo

# Demo Targets
deep-clean: clean
	rm -rf ${GOBIN}/dep
	rm -rf ${GOBIN}/gocov

.PHONY: build clean deep-clean help run test vet
