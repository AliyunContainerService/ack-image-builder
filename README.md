# Image Build Specification of Alibaba Cloud Container Service for Kubernetes (ACK) 

Notes: The template [ack-centos.json](https://github.com/AliyunContainerService/ack-image-builder/blob/master/ack-centos.json) is used for building custom image for ACK cluster based on the latest published ecs centos public image.

This repository contains resources and configuration scripts for building a custom base OS Image for ACK with [HashiCorp Packer](https://www.packer.io/).

## Supported OS

* Alibaba Cloud Linux 3
* Alibaba Cloud Linux 2  - deprecated
* CentOS 7.6/7.7/7.8/7.9 - deprecated
* Red Hat Enterprise Linux 9
* Anolis OS 8


## Setup

You must have [Packer](https://www.packer.io/) installed on your local system. For more information, see [Installing Packer](https://www.packer.io/docs/install/index.html) in the Packer documentation. You must also have Alibaba Cloud account credentials configured so that Packer can make calls to Alibaba Cloud API operations on your behalf.

For more information, see [Alibaba Cloud builder](https://www.packer.io/docs/builders/alicloud-ecs.html) in the Packer documentation.

## Building the OS Image

Execute following scripts in your shell

```
export ALICLOUD_REGION=XXX
export ALICLOUD_ACCESS_KEY=XXX
export ALICLOUD_SECRET_KEY=XXX
packer build examples/ack-aliyunlinux3.json
```

## Build ACK-Optimized-OS image

Execute following scripts in your shell

```
export RUNTIME=XXX
export ALICLOUD_REGION=XXX
export ALICLOUD_ACCESS_KEY=XXX
export ALICLOUD_SECRET_KEY=XXX
packer build examples/ack-optimized-os-all.json
```
NOTE: `RUNTIME` only support `docker` and `containerd`

```shell
{
  "variables": {
    "image_name": "ack-optimized_image-1.28-{{timestamp}}",
    "source_image": "aliyun_3_9_x64_20G_alibase_20231219.vhd",
    "instance_type": "ecs.gn6i-c4g1.xlarge",
    "region": "{{env `ALICLOUD_REGION`}}",
    "access_key": "{{env `ALICLOUD_ACCESS_KEY`}}",
    "secret_key": "{{env `ALICLOUD_SECRET_KEY`}}",
    "runtime": "{{env `RUNTIME`}}",
    "skip_secrutiy_fix": "{{env `SKIP_SECURITY_FIX`}}"
  },
  "builders": [
    {
      "type": "alicloud-ecs",
      "access_key": "{{user `access_key`}}",
      "secret_key": "{{user `secret_key`}}",
      "region": "{{user `region`}}",
      "image_name": "{{user `image_name`}}",
      "source_image": "{{user `source_image`}}",
      "ssh_username": "root",
      "instance_type": "{{user `instance_type`}}",
      "skip_image_validation": "true",
      "io_optimized": "true"
    }
  ],
  "provisioners": [
    {
      "type": "file",
      "source": "scripts/ack-optimized-os-all.sh",
      "destination": "/root/"
    },
    {
      "type": "shell",
      "inline": [
        "export RUNTIME={{user `runtime`}}",
        "export SKIP_SECURITY_FIX={{user `skip_secrutiy_fix`}}",
        "export OS_ARCH=amd64",
        "export PRESET_GPU=true",    # If you want to download gpu, set PRESET_GPU to true and also set instance_type to gpu instance, supports version 1.20+.
        "export NVIDIA_DRIVER_VERSION=460.106.00",   #  You can set the gpu version, default is 460.91.03
        "export KEEP_IMAGE_DATA=true",   #  If you cache images, you must set KEEP_IMAGE_DATA to true
        "export KUBE_VERSION=1.28.9-aliyun.1",   #  Set KUBE_VERSION according to your cluster version
        "bash /root/ack-optimized-os-all.sh",
        "ctr -n k8s.io i pull docker.io/library/nginx:1.7.9"  #  You can cache images into OS image
      ]
    }
  ]
}
```

## RAM Policy

If you are using a sub account，the ram policy should at least include actions as below:

> Note that you'd better release the delete permissions once you have completed your image build task for safety reasons.

```
{
    "Version": "1",
    "Statement": [
        {
            "Action": [
                "ecs:DescribeImages",
                "ecs:CreateImage",
                "ecs:ModifyImageSharePermission",
                "ecs:CreateKeyPair",
                "ecs:DeleteKeyPairs",
                "ecs:DetachKeyPair",
                "ecs:AttachKeyPair",
                "ecs:CreateSecurityGroup",
                "ecs:DeleteSecurityGroup",
                "ecs:AuthorizeSecurityGroupEgress",
                "ecs:AuthorizeSecurityGroup",
                "ecs:CreateSnapshot",
                "ecs:AttachDisk",
                "ecs:DetachDisk",
                "ecs:DescribeDisks",
                "ecs:CreateDisk",
                "ecs:DeleteDisk",
                "ecs:CreateNetworkInterface",
                "ecs:DescribeNetworkInterfaces",
                "ecs:AttachNetworkInterface",
                "ecs:DetachNetworkInterface",
                "ecs:DeleteNetworkInterface",
                "ecs:DescribeInstanceAttribute",
                "ecs:CreateInstance",
                "ecs:DeleteInstance",
                "ecs:StartInstance",
                "ecs:StopInstance",
                "ecs:DescribeInstances"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "vpc:CreateVpc",
                "vpc:DeleteVpc",
                "vpc:DescribeVpcs",
                "vpc:CreateVSwitch",
                "vpc:DeleteVSwitch",
                "vpc:DescribeVSwitches",
                "vpc:AllocateEipAddress",
                "vpc:AssociateEipAddress",
                "vpc:UnassociateEipAddress",
                "vpc:DescribeEipAddresses",
                "vpc:ReleaseEipAddress"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        }
    ]
}
```

## Security

For security issues or concerns, please do not open an issue or pull request on GitHub. Please report any suspected or confirmed security issues to Alibaba Cloud Container Security contact <kubernetes-security@service.aliyun.com>

