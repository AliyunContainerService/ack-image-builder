#!/bin/bash

curl -LO https://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/daemon-build/centos/containerd.io-1.2.10-3.2.el7.x86_64.rpm containerd.io-1.2.10-3.2.el7.x86_64.rpm

yum localinstall -y containerd.io-1.2.10-3.2.el7.x86_64.rpm

rm -rf containerd.io-1.2.10-3.2.el7.x86_64.rpm