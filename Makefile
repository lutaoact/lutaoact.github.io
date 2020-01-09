.PHONY: build exec start stop restart logs

BUILD_DATE=$(shell date +%Y%m%d)
PWD=$(shell pwd)
DOCKER_IMAGE=lutaoact/blog

dev: rebuild
	docker-compose -f docker-compose.yml up --remove-orphans

rebuild:
	docker-compose -f docker-compose.yml build

build_server:
	docker build -t blogserver:latest -f server.dockerfile .

run_server: stop_server
	docker run --name blogserver -p 4000:4000 -d blogserver:latest

stop_server:
	docker stop blogserver; docker rm -f blogserver

exec:
	docker exec -it blog bash

exec_server:
	docker exec -it blogserver bash

serverlog:
	docker logs -f blogserver
