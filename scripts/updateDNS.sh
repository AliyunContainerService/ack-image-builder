#!/bin/bash

# unlock DNS file in case it was locked
# chattr -i /etc/resolv.conf

# Using your custom nameserver to replace xxx.xxx.xxx.xxx
# echo -e "nameserver xxx.xxx.xxx.xxx\nnameserver xxx.xxx.xxx.xxx" > /etc/resolv.conf

# Keep resolv locked to prevent overwriting by cloudinit/NetworkManager
# chattr +i /etc/resolv.conf
