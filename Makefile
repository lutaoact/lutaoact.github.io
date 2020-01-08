.PHONY: build

BUILD_DATE=$(shell date +%Y%m%d)
PWD=$(shell pwd)
DOCKER_IMAGE=lutaoact/blog

build:
	docker build -t $(DOCKER_IMAGE):latest .

exec:
	docker run --rm -it $(DOCKER_IMAGE):latest bash

run:
	docker run --name blog -v ~/lutaoact.github.io:/code $(DOCKER_IMAGE):latest
