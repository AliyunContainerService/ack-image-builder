#!/bin/bash

set -x
set -e

CUR_DIR=$(dirname $(readlink -e -v ${BASH_SOURCE[0]}))
SRC_DIR=$(dirname $CUR_DIR)

usage() {
    cat >&2 <<-EOF
Usage:
    $0 build_template_file
Example:
    $0 $SRC_DIR/examples/ack-aliyunlinux2.json
EOF
}

check_params() {
    BUILD_TEMPLATE_FILE="$1"

    if [[ -z $BUILD_TEMPLATE_FILE ]]; then
        echo "ERROR: must be specify one template file"
        usage
        return 1
    fi

    if ! [[ -f $BUILD_TEMPLATE_FILE ]]; then
        echo "ERROR: cannot find file: $BUILD_TEMPLATE_FILE"
        return 1
    fi
}

check_docker_image() {
    if docker inspect registry.aliyuncs.com/acs/ack-image-builder:v1.0.0 &>/dev/null; then
        :
    else
        make
    fi
}

build_os_image() {
    docker run -v $BUILD_TEMPLATE_FILE:$BUILD_TEMPLATE_FILE registry.aliyuncs.com/acs/ack-image-builder:v1.0.0  $file_path
}

main() {
    check_params "$@"
    check_docker_image
    build_os_image
}

main "$@"

