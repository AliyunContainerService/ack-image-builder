#!/bin/bash
public::common::log() {
    echo $(date +"[%Y%m%d %H:%M:%S]: ") $1
}
public::common::prepare_package() {
    PKG_TYPE=$1
    PKG_VERSION=$2
    if [ ! -f ${PKG_TYPE}-${PKG_VERSION}.tar.gz ]; then
        curl --retry 4 $PKG_FILE_SERVER/$CLOUD_TYPE/pkg/$PKG_TYPE/${PKG_TYPE}-${PKG_VERSION}.tar.gz \
            >${PKG_TYPE}-${PKG_VERSION}.tar.gz || (public::common::log "download failed with 4 retry,exit 1" && exit 1)
    fi
    tar -xvf ${PKG_TYPE}-${PKG_VERSION}.tar.gz || (public::common::log "untar ${PKG_VERSION}.tar.gz failed!, exit" && exit 1)
}

public::docker::install() {
	set +e
	docker version >/dev/null 2>&1
	i=$?
	set -e
	v=$(docker version | grep Version | awk '{gsub(/-/, ".");print $2}' | uniq)
	if [ $i -eq 0 ]; then
		if [[ "$DOCKER_VERSION" == "$v" ]]; then
			public::common::log "docker has been installed , return. $DOCKER_VERSION"
			return
		fi
	fi
	public::common::prepare_package "docker" $DOCKER_VERSION
	if [ "$OS" == "CentOS" ] || [ "$OS" == "RedHat" ] || [ "$OS" == "AliOS" ] || [ "$OS" == "AliyunOS" ]; then
		if type docker; then
			if [ "$(rpm -qa docker-engine-selinux | wc -l)" == "1" ]; then
				yum erase -y docker-engine-selinux
			fi
			if [ "$(rpm -qa docker-engine | wc -l)" == "1" ]; then
				yum erase -y docker-engine
			fi
			if [ "$(rpm -qa docker-ce | wc -l)" == "1" ]; then
				yum erase -y docker-ce
			fi
			if [ "$(rpm -qa container-selinux | wc -l)" == "1" ]; then
				yum erase -y container-selinux
			fi
			if [ "$(rpm -qa docker-ee | wc -l)" == "1" ]; then
				yum erase -y docker-ee
			fi
		fi

		local pkg=pkg/docker/$DOCKER_VERSION/rpm/
		if [ "$OS" == "AliOS" ]; then
			set +e
			set +o pipefail
			for package in $(ls $pkg | xargs -I '{}' echo -n "$pkg{} "); do
				rpm -qp ${package} --requires |\
				grep -v container-selinux | grep -v 'rpmlib'| awk '{print $1}'|xargs -n1 yum install -y
				rpm -ivh --nodeps ${package}
			done
		else
			yum localinstall -y $(ls $pkg | xargs -I '{}' echo -n "$pkg{} ")
		fi
	elif [ "$OS" == "Ubuntu" ]; then
		if [ "$need_reinstall" == "true" ]; then
			if [ "$(echo $v | grep ee | wc -l)" == "1" ]; then
				apt purge -y docker-ee docker-ee-selinux
			elif [ "$(echo $v | grep ce | wc -l)" == "1" ]; then
				apt purge -y docker-ce docker-ce-selinux container-selinux
			else
				apt purge -y docker-engine
			fi
		fi

		dir=pkg/docker/$DOCKER_VERSION/debain
		dpkg -i $(ls $dir | xargs -I '{}' echo -n "$dir/{} ")
	elif [ "$OS" == "SUSE" ]; then
		if type docker; then
			if [ "$(rpm -qa docker-engine-selinux | wc -l)" == "1" ]; then
				zypper rm -y docker-engine-selinux
			fi
			if [ "$(rpm -qa docker-engine | wc -l)" == "1" ]; then
				zypper rm -y docker-engine
			fi
			if [ "$(rpm -qa docker-ce | wc -l)" == "1" ]; then
				zypper rm -y docker-ce
			fi
			if [ "$(rpm -qa container-selinux | wc -l)" == "1" ]; then
				zypper rm -y container-selinux
			fi
			if [ "$(rpm -qa docker-ee | wc -l)" == "1" ]; then
				zypper rm -y docker-ee
			fi
		fi

		local pkg=pkg/docker/$KUBE_VERSION/rpm/
		zypper --no-gpg-checks install -y $(ls $pkg | xargs -I '{}' echo -n "$pkg{} ")
	else
		public::common::log "install docker with [unsupported OS version] error!"
		exit 1
	fi
}
main() {
   public::common::prepare_package "docker" "$DOCKER_VERSION"
   public::common::prepare_package "kubernetes" $KUBE_VERSION
   public::docker::install
}
main "$@"

