.PHONY: build exec start stop restart logs

BUILD_DATE=$(shell date +%Y%m%d)
PWD=$(shell pwd)
DOCKER_IMAGE=lutaoact/blog

build:
	docker build -t $(DOCKER_IMAGE):latest -f development-environment.dockerfile .

build_dist:
	docker build -t blogdist:latest -f dist.dockerfile .

rebuild:
	docker-compose -f docker-compose.yml      build
	docker-compose -f docker-compose-dist.yml build

run_dist:
	docker-compose -f docker-compose-dist.yml up -d

exec:
	docker exec -it blog bash

run:
	docker-compose -f docker-compose.yml up

logs:
	docker logs -f blog

restart: stop start
