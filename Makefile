.PHONY: build exec start stop restart logs

BUILD_DATE=$(shell date +%Y%m%d)
PWD=$(shell pwd)
DOCKER_IMAGE=blogserver

dev: rebuild
	docker-compose -f docker-compose.yml up --remove-orphans

rebuild:
	docker-compose -f docker-compose.yml build

build_server:
	docker build -t $(DOCKER_IMAGE):latest -f server.dockerfile .

run_server: stop_server
	docker run --name blogserver -p 4000:4000 -d $(DOCKER_IMAGE):latest

stop_server:
	docker stop blogserver; docker rm -f blogserver

push: rebuild
	docker tag $(DOCKER_IMAGE):latest lutaoact/$(DOCKER_IMAGE):latest
	docker push lutaoact/$(DOCKER_IMAGE):latest

exec:
	docker exec -it blog bash

exec_server:
	docker exec -it blogserver bash

serverlog:
	docker logs -f blogserver
