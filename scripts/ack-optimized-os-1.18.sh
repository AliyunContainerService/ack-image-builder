#!/bin/bash

set -x
set -e

SRC_DIR=$(dirname $(readlink -e -v $0))
OS="AliyunOS"
DOCKER_VERSION="19.03.5"
KUBE_VERSION="1.18.8-aliyun.1"
REGION=$(curl --retry 10 -sSL http://100.100.100.200/latest/meta-data/region-id)
PKG_FILE_SERVER="http://aliacs-k8s-$REGION.oss-$REGION-internal.aliyuncs.com/$BETA_VERSION"
ACK_OPTIMIZED_OS_BUILD=1

download_pkg() {
    curl --retry 4 $PKG_FILE_SERVER/public/pkg/run/run-${KUBE_VERSION}.tar.gz -O
    tar -xvf run-${KUBE_VERSION}.tar.gz
}

source_file() {
    source pkg/run/$KUBE_VERSION/kubernetes.sh --role source
}

install_pkg() {
    public::common::sync_ntpd
    public::common::install_package
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
    for pkg in $pkg_list; do
        yum remove -y $pkg
    done

    rm -rf /lib/modules/$(uname -r)/kernel/drivers/{media,staging,gpu,usb}
    rm -rf /boot/*-rescue-* /boot/*3.10.0* /usr/share/{doc,man} /usr/src
}

pull_image() {
    systemctl start docker
    sleep 3

    docker pull  registry-vpc.${REGION}.aliyuncs.com/acs/kube-proxy:v${KUBE_VERSION}
    docker pull  registry-vpc.${REGION}.aliyuncs.com/acs/pause:3.2
    docker pull  registry-vpc.${REGION}.aliyuncs.com/acs/coredns:1.6.7
}

update_os_release() {
    sed -i  "s#LTS#LTS ACK-Optimized-OS#"  /etc/image-id
}

record_k8s_version() {
    cat > /etc/ACK-Optimized-OS <<-EOF
kubelet=$KUBE_VERSION
docker=$DOCKER_VERSION
EOF
}

cleanup() {
    rm -rf ./{addon*,docker*,kubernetes*,pkg,run*}
}

main() {
    trap 'cleanup' EXIT

    download_pkg
    source_file

    trim_os
    install_pkg

    pull_image
    update_os_release
    record_k8s_version
}

main
