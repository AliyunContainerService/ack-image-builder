#!/bin/bash
##
read  -p "Please input the AliCloud access_key:" ACCESS_KEY
read  -p "Please input the AliCloud secret_key:" SECRET_KEY
read  -p "The Alicloud region is: " REGION
read  -p "The Docker version is:" DOCKER_VERSION
read  -p "The kubernetes version is:" KUBE_VERSION

## check params
if [[ -z $ACCESS_KEY || -z $SECRET_KEY || -z $REGION ]]; then
   printf "[ERROR] `date '+%F %T'` following parameters is empty:\naccess_key=${ACCESS_KEY}\nsecret_key=${SECRET_KEY}\nregion=${REGION}\ninstance_type=${INSTANCE_TYPE}\nsource_image=${SOURCE_IMAGE}\nimage_name=${IMAGE_NAME}"
   exit 0
fi

##build OS image
docker run -e ALICLOUD_ACCESS_KEY=$ACCESS_KEY -e ALICLOUD_SECRET_KEY=$SECRET_KEY  -e REGION=$REGION  -e KUBE_VERSION=$KUBE_VERSION \
-e DOCKER_VERSION=$DOCKER_VERSION  registry.aliyuncs.com/acs/ack-image-builder:v1.0.0  $1