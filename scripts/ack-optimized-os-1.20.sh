#!/bin/bash

set -x
set -e

usage() {
    cat >&2 <<-EOF
Usage:
    $0 -r RUNTIME [-s]

Flags:
    -r: sepcify container runtime, available value: docker and containerd
    -s: skip security upgrade

Example:
    $0 -r docker -s
    $0 -r docker
    $0 -r containerd -s
    $0 -r containerd
EOF
    exit 1
}

check_params() {
    while getopts "r:sh" opt; do
        case $opt in
        r) RUNTIME="$OPTARG" ; ;;
        s) SKIP_SECURITY_FIX="1" ; ;;
        h | ?) usage ; ;;
        esac
    done

    if [[ -z $RUNTIME ]] || [[ $RUNTIME != "docker" && $RUNTIME != "containerd" ]]; then
        echo "ERROR: RUNTIME must not be empty, only support 'docker' and 'containerd' "
        usage
    fi
}

setup_env() {
    export RUNTIME
    export OS="AliyunOS"
    export RUNTIME_VERSION="1.4.4"
    export DOCKER_VERSION="19.03.5"
    export CLOUD_TYPE="public"
    export KUBE_VERSION="1.20.11-aliyun.1"
    export REGION=$(curl --retry 10 -sSL http://100.100.100.200/latest/meta-data/region-id)
    export PKG_FILE_SERVER="http://aliacs-k8s-$REGION.oss-$REGION-internal.aliyuncs.com/"
    export ACK_OPTIMIZED_OS_BUILD=1

    mkdir -p /root/ack-deploy
    cd /root/ack-deploy

}

trim_os() {
    local pkg_list="acl
aic94xx-firmware
aliyun-cli
alsa-firmware
alsa-lib
alsa-tools-firmware
authconfig
avahi-libs
bind-libs-lite
bind-license
biosdevname
btrfs-progs
cloud
device-mapper-event
device-mapper-event-libs
dmraid
dmraid-events
dosfstools
ed
file
firewalld
firewalld-filesystem
freetype
fxload
GeoIP
geoipupdate
gettext
gettext-libs
glibc-devel
groff-base
hunspell
hunspell-en
hunspell-en-GB
hunspell-en-US
ivtv-firmware
iwl1000-firmware
iwl100-firmware
iwl105-firmware
iwl135-firmware
iwl2000-firmware
iwl2030-firmware
iwl3160-firmware
iwl3945-firmware
iwl4965-firmware
iwl5000-firmware
iwl5150-firmware
iwl6000-firmware
iwl6000g2a-firmware
iwl6000g2b-firmware
iwl6050-firmware
iwl7260-firmware
jansson
kbd
kbd-legacy
kbd-misc
libaio
libdrm
libfastjson
libmpc
libpciaccess
libpng
libreport-filesystem
lm_sensors-libs
lsscsi
lvm2
m4
mailx
man-db
mariadb-libs
mdadm
microcode_ctl
mpfr
NetworkManager
NetworkManager-libnm
NetworkManager-team
NetworkManager-tui
patch
perl-Getopt-Long
plymouth
plymouth-scripts
postfix
python3
python3-libs
python3-pip
python3-setuptools
python-decorator
python-IPy
rng-tools
rsync
rsyslog
sgpio
slang
spax
strace
sysstat
tcpdump
teamd
vim-common
vim-enhanced
vim-filesystem
wl1000-firmware
wpa_supplicant
xfsprogs
"

    yum remove -y $pkg_list
    rm -rf /lib/modules/$(uname -r)/kernel/drivers/{media,staging,gpu,usb}
    rm -rf /boot/*-rescue-* /boot/*3.10.0* /usr/share/{doc,man} /usr/src
}

download_pkg() {
    curl --retry 4 $PKG_FILE_SERVER/public/pkg/run/run-${KUBE_VERSION}.tar.gz -O
    tar -zxvf run-${KUBE_VERSION}.tar.gz
}

install_pkg() {
    ROLE=deploy-nodes pkg/run/$KUBE_VERSION/bin/kubernetes.sh
}

preset_gpu() {
    if [[ $PRESET_GPU ]]; then
        bash pkg/run/$KUBE_VERSION/bin/nvidia-gpu-installer.sh
    fi
}

pull_image() {
    if [[ "$RUNTIME" = "docker" ]]; then
        systemctl start docker
        sleep 10

        docker pull registry-vpc.${REGION}.aliyuncs.com/acs/kube-proxy:v${KUBE_VERSION}
        docker pull registry-vpc.${REGION}.aliyuncs.com/acs/pause:3.2
        docker pull registry-vpc.${REGION}.aliyuncs.com/acs/coredns:1.7.0
    else
        systemctl start containerd
        sleep 10

        ctr -n k8s.io i pull registry-vpc.${REGION}.aliyuncs.com/acs/kube-proxy:v${KUBE_VERSION}
        ctr -n k8s.io i pull registry-vpc.${REGION}.aliyuncs.com/acs/pause:3.2
        ctr -n k8s.io i pull registry-vpc.${REGION}.aliyuncs.com/acs/coredns:1.7.0
    fi
}

update_os_release() {
    sed -i "s#LTS#LTS ACK-Optimized-OS#" /etc/image-id
}

record_k8s_version() {
    cat >/etc/ACK-Optimized-OS <<-EOF
kubelet=$KUBE_VERSION
runtime=$RUNTIME
docker=$DOCKER_VERSION
EOF
}

post_install() {
    if [[ $SKIP_SECURITY_FIX ]]; then
        touch /var/.skip-security-fix
    fi
}

cleanup() {
    rm -rf /root/ack-deploy
}

main() {
    trap 'cleanup' EXIT

    check_params "$@"
    setup_env

    trim_os

    download_pkg
    install_pkg
    preset_gpu
    pull_image
    update_os_release
    record_k8s_version
    post_install
}

main "$@"
