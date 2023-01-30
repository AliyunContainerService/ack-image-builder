#!/bin/bash

if [[ ! -z $CGROUP_MODE ]] && [[ $CGROUP_MODE =~ .*[v,V]2.* ]]; then
    echo "set cgroup mode to $CGROUP_MODE"
    if ! grep -q 'systemd.unified_cgroup_hierarchy=1' /etc/default/grub; then
        grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1"
        grubby --update-kernel=ALL --args="cgroup_no_v1=all"
    fi
fi


