all: docker-container

PREFIX?=registry.aliyuncs.com/acs
VERSION?=v1.0.0

docker-container:
	docker build --pull -t  $(PREFIX)/ack-image-builder:$(VERSION) -f build/Dockerfile .

.PHONY: all docker-container