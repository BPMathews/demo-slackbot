MAKEFLAGS += --silent

# Define the environment
ENV_FILE := dev.env
PROJECT_NAME := $(shell basename -s .git `git config --get remote.origin.url`)
GOBIN := ${GOPATH}/bin
PWD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Build Vars
BUILD_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BUILD_TIME := $(shell date)
BUILD_VERSION := $(shell git describe --always --dirty)

# Linker Flags
LINKER_FLAGS := -X '\''$(PROJECT_NAME)/env.Version=$(BUILD_VERSION)'\''
LINKER_FLAGS += -X '\''$(PROJECT_NAME)/env.Branch=$(BUILD_BRANCH)'\''
LINKER_FLAGS += -X '\''$(PROJECT_NAME)/env.BuildTime=$(BUILD_TIME)'\''

all: help

## build: Build the application.
build: ${PROJECT_NAME}

## clean: Remove all build atrifacts and generated files.
clean:
	rm -f ${PROJECT_NAME}
	rm -rf vendor
	rm -f Gopkg.lock
	go clean -x

## help: Print out a list of available build targets.
help:
	echo "Make targets available for '${PROJECT_NAME}'"
	echo
	sed -n 's/^##//p' ${PWD}/Makefile | column -t -s ':' | sed -e 's/^/ /'
	echo

## run: Start the application.
run: build
	./${PROJECT_NAME}

# Non-User make targets
vendor: ${GOBIN}/dep Gopkg.toml
	echo "Pulling dependencies..."
	dep ensure -v

${GOBIN}/dep:
	echo "Installing 'Dep'"
	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

${PROJECT_NAME}: Makefile vendor *.go
	echo "Building '${PROJECT_NAME}'..."
	go fmt ./...
	go build -ldflags='$(LINKER_FLAGS)' -o ${PROJECT_NAME}

# Demo Targets
deep-clean: clean
	rm ${GOBIN}/dep

.PHONY: build clean deep-clean help run
