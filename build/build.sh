#!/bin/bash
##
read  -p "Please input the AliCloud access_key:" ACCESS_KEY
read  -p "Please input the AliCloud secret_key:" SECRET_KEY
read  -p "The Alicloud region is: " REGION
read  -p "The Docker version is:" DOCKER_VERSION
read  -p "The kubernetes version is:" KUBE_VERSION

## check params
if [[ -z $ACCESS_KEY || -z $SECRET_KEY || -z $REGION || -z $DOCKER_VERSION || -z $KUBE_VERSION ]]; then
   echo -e "[ERROR] $(date '+%F %T') following parameters is empty:
access_key=${ACCESS_KEY}
secret_key=${SECRET_KEY}
region=${REGION}
docker_version=${DOCKER_VERSION}
kube_version=${KUBE_VERSION}"
   exit 0
fi


file_path="$(pwd)/$1"

##build OS image
docker run -e ALICLOUD_ACCESS_KEY=$ACCESS_KEY -e ALICLOUD_SECRET_KEY=$SECRET_KEY  -e REGION=$REGION  -e KUBE_VERSION=$KUBE_VERSION \
-e DOCKER_VERSION=$DOCKER_VERSION  -v $file_path:$file_path registry.aliyuncs.com/acs/ack-image-builder:v1.0.0  $file_path
