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

    if [[ "$RUNTIME" = "docker" ]]; then
      RUNTIME_VERSION=${RUNTIME_VERSION:-19.03.15}
      export RUNTIME_VERSION
      DOCKER_VERSION=${RUNTIME_VERSION:-19.03.15}
      export DOCKER_VERSION
    else
      RUNTIME_VERSION=${RUNTIME_VERSION:-1.6.20}
      export RUNTIME_VERSION
    fi

    export RELEASE_VERSION=$(echo $KUBE_VERSION | awk -F. '{print $1"."$2}')

    export REGION=$(curl --retry 10 -sSL http://100.100.100.200/latest/meta-data/region-id)
    export PKG_FILE_SERVER="http://aliacs-k8s-$REGION.oss-$REGION-internal.aliyuncs.com/$BETA_VERSION"
    export ACK_OPTIMIZED_OS_BUILD=1

    # setup k8s pull image prefix
    if [[ -z "$KUBE_REPO_PREFIX" && -n "$REGION" ]]; then
      export KUBE_REPO_PREFIX=registry-vpc.$REGION.aliyuncs.com/acs
    fi
}


download_pkg() {
    if [[ $(echo "${KUBE_VERSION}" | cut -d. -f1) -ge 1 && $(echo "${KUBE_VERSION}" | cut -d. -f2) -ge 20 ]]; then
      export RELEASE_VERSION=$(echo $KUBE_VERSION | awk -F. '{print $1"."$2}')
      curl --retry 4 $PKG_FILE_SERVER/public/pkg/run/run-${RELEASE_VERSION}-linux-${OS_ARCH}.tar.gz -O
      tar -xvf run-${RELEASE_VERSION}-linux-${OS_ARCH}.tar.gz
    else
      curl --retry 4 $PKG_FILE_SERVER/public/pkg/run/run-${KUBE_VERSION}.tar.gz -O
      tar -xvf run-${KUBE_VERSION}.tar.gz
    fi
}


source_file() {
    if [[ -e "pkg/run/$KUBE_VERSION/kubernetes.sh" ]]; then
      source pkg/run/$KUBE_VERSION/kubernetes.sh --role source
      install_pkg
    elif [[ -e "pkg/run/$RELEASE_VERSION/bin/kubernetes.sh" ]]; then
      ROLE=deploy-nodes pkg/run/$RELEASE_VERSION/bin/kubernetes.sh
    fi
}

install_pkg() {
    public::common::sync_ntpd
    public::common::install_package
}

preset_gpu() {

    if [[ $(echo "${KUBE_VERSION}" | cut -d. -f2) -lt 20 ]]; then
      return
    fi

    if [[ "$PRESET_GPU" == "true" ]]; then
      for file_name in $(ls pkg/run/$RELEASE_VERSION/lib | grep -v init.sh); do
          source pkg/run/$RELEASE_VERSION/lib/$file_name
      done

      if [[ $NVIDIA_DRIVER_VERSION == "" ]];then
          export NVIDIA_DRIVER_VERSION=460.91.03
      fi

      nvidia::create_dir
      # --nvidia-driver-runfile   指定驱动文件路径
      nvidia::prepare_driver_package
      # --nvidia-container-toolkit-rpms    指定nvidia container toolkit包含的rpm包所在目录
      nvidia::prepare_container_runtime_package
      # --nvidia-fabricmanager-rpm     指定nvidia fabric manager安装包（rpm格式）路径
      nvidia::prepare_driver_package
      # --nvidia-device-plugin-yaml     指定nvidia device plugin yaml文件路径
      nvidia::deploy_static_pod

      if [[ $RUNTIME == "docker" ]];then
        export SKIP_CONTAINER_RUNTIME_CONFIG=true
      fi

      nvidia::gpu::installer::main

    fi
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
libmpc
libpciaccess
libpng
lm_sensors-libs
lsscsi
lvm2
m4
mailx
man-db
mariadb-libs
mdadm
microcode_ctl
patch
perl-Getopt-Long
plymouth
plymouth-scripts
postfix
python3
python3-pip
python3-setuptools
python-decorator
python-IPy
rng-tools
rsync
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

pull_image() {
    if [[ "$RUNTIME" = "docker" ]]; then
        systemctl start docker
        sleep 10

        docker pull registry-${REGION}-vpc.ack.aliyuncs.com/acs/kube-proxy:v${KUBE_VERSION}
        docker pull registry-vpc.${REGION}.aliyuncs.com/acs/pause:3.5
        docker pull registry-vpc.${REGION}.aliyuncs.com/acs/coredns:1.6.7
    else
        systemctl start containerd
        sleep 10

        ctr -n k8s.io i pull registry-${REGION}-vpc.ack.aliyuncs.com/acs/kube-proxy:v${KUBE_VERSION}
        ctr -n k8s.io i pull registry-vpc.${REGION}.aliyuncs.com/acs/pause:3.5
        ctr -n k8s.io i pull registry-vpc.${REGION}.aliyuncs.com/acs/coredns:1.6.7
    fi
}

update_os_release() {
    if [[ ! -f /etc/image-id ]]; then
      touch /etc/image-id
    fi
    sed -i  "s#LTS#LTS ACK-Optimized-OS#"  /etc/image-id
}

record_k8s_version() {
    cat > /etc/ACK-Optimized-OS <<-EOF
kubelet=$KUBE_VERSION
docker=$DOCKER_VERSION
EOF
}

post_install() {
    if [[ $SKIP_SECURITY_FIX ]]; then
        touch /var/.skip-security-fix
    fi
}

keep_container_data() {
    if [[ "$KEEP_IMAGE_DATA" = "true" ]]; then
        touch /var/.keep-container-data
    fi
}

cleanup() {
    rm -rf ./{addon*,docker*,kubernetes*,pkg,run*}
}

main() {
    trap 'cleanup' EXIT

    check_params "$@"
    setup_env

#    trim_os

    download_pkg
    source_file
    preset_gpu
    pull_image
    keep_container_data
    update_os_release
    record_k8s_version
}

main "$@"
