#!/usr/bin/env bash


public::common::log() {
    if [ $2 == "fail" ];then
        echo -e $(date +"[%Y%m%d %H:%M:%S]: ") $1 "\033[31m Verify Failed! \033[0m"
    else
        echo -e $(date +"[%Y%m%d %H:%M:%S]: ") $1 "\033[32m Verify Passed! \033[0m"
    fi
}

# func for checking kernel version >= 3.10
public::check::kernel() {
    current_kernel_version=$(uname -r)
    required_kernel_version=3.10

    if [ "$(printf '%s\n' "$required_kernel_version" "$current_kernel_version" | sort -V | head -n1)" = "$required_kernel_version" ] ;then
        public::common::log "Check if kernel version >= $required_kernel_version." "pass"
    else
        public::common::log "Check if kernel version >= $required_kernel_version." "fail"
        exit 1
    fi
}

# check kernel version >= 3.10
public::check::kernel


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


# func for checking if cloud-init is installed
public::check::cloudinit() {
    which cloud-init >/dev/null 2>&1
    if [ $? -ne 0 ];then
        public::common::log "Check if cloud-init is installed." "fail"
        exit 1
    else
        public::common::log "Check if cloud-init is installed." "pass"
    fi
}

# check if cloud-init is installed
public::check::cloudinit


# func for checking if clean up kubeadm
public::check::kubeadm() {
    which kubeadm >/dev/null 2>&1
    if [ $? -ne 0 ];then
        public::common::log "Check if clean up kubeadm." "pass"
    else
        public::common::log "Check if clean up kubeadm." "fail"
        exit 1
    fi
}

# check if clean up kubeadm
public::check::kubeadm


#TODO
#E.g. Check chronyd or ntpd is configured properly

#E.g. Check iptables
