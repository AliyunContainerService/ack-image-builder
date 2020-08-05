#! /bin/bash

# check if image_id="aliyun_2_1903_x64_20G_alibase_20200529.vhd" and tuned service is off

if [ -f "/etc/image-id" ]; then
    image_id=$(cat /etc/image-id |grep image_id |cut -d "=" -f2)

    if [ "$image_id" = "\"aliyun_2_1903_x64_20G_alibase_20200526.vhd\"" ] || [ "$image_id" = "\"aliyun_2_1903_x64_20G_alibase_20200529.vhd\"" ]; then
        systemctl stop tuned
        systemctl disable tuned
        echo "Succesfully stop and disable tuned"
    fi
fi