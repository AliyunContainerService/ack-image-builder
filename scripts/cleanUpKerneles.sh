#!/bin/bash

rpm -q kernel

yum install -y yum-utils

package-cleanup --oldkernels --count=1 -y

yum -y remove yum-utils

