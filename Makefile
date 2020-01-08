.PHONY: build exec start stop restart logs

BUILD_DATE=$(shell date +%Y%m%d)
PWD=$(shell pwd)
DOCKER_IMAGE=lutaoact/blog

build:
	docker build -t $(DOCKER_IMAGE):latest -f development-environment.dockerfile .

exec:
	docker exec -it blog bash

run:
	docker-compose -f docker-compose.yml up

logs:
	docker logs -f blog

restart: stop start
