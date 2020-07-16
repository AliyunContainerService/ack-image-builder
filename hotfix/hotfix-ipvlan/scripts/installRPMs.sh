#!/bin/bash

curl -LO http://xxx.xx.xx.xxx/kernel-4.19.91-0.1.git.6eb3a5047051.al7.x86_64.rpm
curl -LO http://xxx.xx.xx.xxx/kernel-headers-4.19.91-0.1.git.6eb3a5047051.al7.x86_64.rpm

yum localinstall -y kernel-4.19.91-0.1.git.6eb3a5047051.al7.x86_64.rpm kernel-headers-4.19.91-0.1.git.6eb3a5047051.al7.x86_64.rpm

rm -rf kernel-4.19.91-0.1.git.6eb3a5047051.al7.x86_64.rpm kernel-headers-4.19.91-0.1.git.6eb3a5047051.al7.x86_64.rpm