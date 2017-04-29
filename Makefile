SHELL=/bin/bash
ifndef ELASTIC_VERSION
ELASTIC_VERSION=5.3.1
endif

ifndef SG_VERSION
SG_VERSION=12
endif

#########################
#########################

IMAGETAG=$(ELASTIC_VERSION)-$(SG_VERSION)
ES_DOWNLOAD_URL=https://artifacts.elastic.co/downloads/elasticsearch
ELASTIC_REGISTRY=docker.elastic.co
SG_REPO=searchguard-stage
BASEIMAGE=$(ELASTIC_REGISTRY)/elasticsearch/elasticsearch-alpine-base:latest
VERSIONED_IMAGE=floragunncom/$(SG_REPO):$(IMAGETAG)
LATEST_IMAGE=floragunncom/$(SG_REPO):latest

export ELASTIC_VERSION
export ES_DOWNLOAD_URL
export ES_JAVA_OPTS
export VERSIONED_IMAGE
export SG_VERSION
export DOCKER_ID_USER="floragunncom"

.PHONY: build clean cluster-unicast-test pull-latest-baseimage push run-es-cluster run-es-single single-node-test test run-sgadmin

# Default target, build *and* run tests
test: single-node-test cluster-unicast-test

# Common target to ensure BASEIMAGE is latest
pull-latest-baseimage:
	docker pull $(BASEIMAGE)

# Clean up left over containers and volumes from earlier failed runs
clean:
	docker-compose down -v && docker-compose rm -f -v

run-es-single: pull-latest-baseimage clean
	ES_NODE_COUNT=1 docker-compose -f docker-compose.yml -f docker-compose.hostports.yml up --build elasticsearch1

run-es-cluster: pull-latest-baseimage clean
	ES_NODE_COUNT=2 docker-compose -f docker-compose.yml -f docker-compose.hostports.yml up --build elasticsearch1 elasticsearch2
	
run-sgadmin: pull-latest-baseimage clean
	docker-compose -f docker-compose.yml -f docker-compose.hostports.yml up --build sgadmin
	
run-netty-tcnative-alpine: clean
	docker-compose -f docker-compose.yml -f docker-compose.hostports.yml up --build netty-tcnative-alpine

single-node-test: export ES_NODE_COUNT=1
single-node-test: pull-latest-baseimage clean
	docker-compose up -d --build elasticsearch1
	docker-compose build --pull tester
	docker-compose build --pull sgadmin
	sleep 20
	docker-compose run sgadmin
	docker-compose run tester
	docker-compose down -v

cluster-unicast-test: export ES_NODE_COUNT=2
cluster-unicast-test: pull-latest-baseimage clean
	docker-compose up -d --build elasticsearch1 elasticsearch2
	docker-compose build --pull tester
	docker-compose build --pull sgadmin
	sleep 20
	docker-compose run sgadmin
	docker-compose run tester
	docker-compose down -v

# Build docker image: "elasticsearch:$(IMAGETAG)"
build: pull-latest-baseimage clean
	docker-compose build --pull elasticsearch1
	docker-compose build --pull sgadmin

# Push to registry. Only push latest if not a staging build.
push: test
	echo "Push $(VERSIONED_IMAGE)"
	docker push $(VERSIONED_IMAGE)
	docker push $(VERSIONED_IMAGE)-sgadmin

pushdev: build
	echo "Push $(VERSIONED_IMAGE)"
	docker push $(VERSIONED_IMAGE)
	docker push $(VERSIONED_IMAGE)-sgadmin
