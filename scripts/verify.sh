#!/usr/bin/env bash

REQUIRED_TOOLS=("cloud-init" "wget" "curl")
CLEANUP_TOOLS=("kubeadm" "kubelet" "kubectl" "kubernetes-cni")
REQUIRED_KERNEL_VERSION=3.10
REQUIRED_SYSTEMD_VERSION=219

public::common::log() {
    if [ $2 == "fail" ];then
        echo -e $(date +"[%Y%m%d %H:%M:%S]: ") $1 "\033[31m Verify Failed! \033[0m"
    else
        echo -e $(date +"[%Y%m%d %H:%M:%S]: ") $1 "\033[32m Verify Passed! \033[0m"
    fi
}

# func for checking kernel version >= $REQUIRED_KERNEL_VERSION
public::check::kernel() {
    current_kernel_version=$(uname -r)

    if [ "$(printf '%s\n' "$REQUIRED_KERNEL_VERSION" "$current_kernel_version" | sort -V | head -n1)" = "$REQUIRED_KERNEL_VERSION" ] ;then
        public::common::log "Check if kernel version >= $REQUIRED_KERNEL_VERSION." "pass"
    else
        public::common::log "Check if kernel version >= $REQUIRED_KERNEL_VERSION." "fail"
        exit 1
    fi
}

# check kernel version >= $REQUIRED_KERNEL_VERSION
public::check::kernel

# func for checking systemd version >= $REQUIRED_SYSTEMD_VERSION
public::check::systemd() {
    current_systemd_version=$(systemctl --version|grep systemd |cut -d " " -f2)

    if [ "$(printf '%s\n' "$REQUIRED_SYSTEMD_VERSION" "$current_systemd_version" | sort -V | head -n1)" = "$REQUIRED_SYSTEMD_VERSION" ] ;then
        public::common::log "Check if systemd version >= $REQUIRED_SYSTEMD_VERSION." "pass"
    else
        public::common::log "Check if systemd version >= $REQUIRED_SYSTEMD_VERSION." "fail"
        exit 1
    fi
}

# check systemd version >= $REQUIRED_SYSTEMD_VERSION
public::check::systemd


# func for checking if sshd is running and listen on port 22
public::check::sshd() {
    netstat -tlpn | grep "\b22\b" |grep sshd >/dev/null 2>&1
    if [ $? -ne 0 ];then
        public::common::log "Check if sshd is running and listen on port 22." "fail"
        exit 1
    else
        public::common::log "Check if sshd is running and listen on port 22." "pass"
    fi
}

# check if sshd is running and listen on port 22
public::check::sshd


# func for checking if required tools are installed
public::check::requiredtools() {
    for required_tool in ${REQUIRED_TOOLS[@]}
    do
        which $required_tool >/dev/null 2>&1
        if [ $? -ne 0 ];then
            public::common::log "Check if $required_tool is installed." "fail"
            exit 1
        else
            public::common::log "Check if $required_tool is installed." "pass"
        fi
    done
}

# check if required tools are installed
public::check::requiredtools


# func for checking if tools are cleaned up
public::check::cleanuptools() {
    for cleanup_tool in ${CLEANUP_TOOLS[@]}
    do
        which $cleanup_tool >/dev/null 2>&1
        if [ $? -ne 0 ];then
            public::common::log "Check if $cleanup_tool is cleaned up." "pass"
        else
            public::common::log "Check if $cleanup_tool is cleaned up." "fail"
            exit 1
        fi
    done
}

# check if clean up kubeadm
public::check::cleanuptools


#TODO
#E.g. Check chronyd or ntpd is configured properly

#E.. Check iptables
