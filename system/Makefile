# Author: Chau Tran

SHELL := /bin/bash -e

# Remove spark, hive image
CUSTOMIZED_IMAGES := hadoop hive postgresql-hms
VERSION := 1.0.0

############################################
########## DOCKER BUILD IMAGES #############
############################################

build-hdfs-base:
	# If the image already exists, not rebuild it
ifeq ("$(shell docker images | grep -c hdfs-base)","0")
	docker build --build-arg UID="$$(id -u)" --build-arg GID="$$(id -g)" --rm -t hdfs-base:$(VERSION) -f docker/docker.base .;
endif

build-images: build-hdfs-base
    # If the image already exists, not rebuild it
	@for image in $(CUSTOMIZED_IMAGES) ; do \
	    if [[ "$(shell docker images | grep -c $$"image")" = "0" ]]; then \
	        docker build --build-arg VERSION=$(VERSION) --rm -t $$image:$(VERSION) -f $$image/Dockerfile .; \
        fi \
	done

build: build-images

####################################################
########## DOCKER LOGIN PULL/PUSH ##################
####################################################

# Login docker hub
# docker-login:
# 	docker login --email=$(DOCKER_EMAIL) --password=$(DOCKER_PASSWORD) --username=$(DOCKER_USERNAME)

# Push image to login
# push-images: build
# 	for image in $(IMAGES) ; do make -C $$image push-image; done
