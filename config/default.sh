# /bin/bash

# Set timezone
timedatectl set-timezone Asia/Shanghai

# Set swap off
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
