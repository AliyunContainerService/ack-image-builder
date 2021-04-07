# Image Build Specification of Alibaba Cloud Container Service for Kubernetes (ACK) 

Notes: The template [ack-centos.json](https://github.com/AliyunContainerService/ack-image-builder/blob/master/ack-centos.json) is used for building custom image for ACK cluster based on the latest published ecs centos public image.

This repository contains resources and configuration scripts for building a custom base OS Image for ACK with [HashiCorp Packer](https://www.packer.io/).

## Supported OS

* CentOS 7.6/7.7/7.8/7.9
* Aliyun Linux 2 (Alibaba Cloud Linux 2)

## Setup

You must have [Packer](https://www.packer.io/) installed on your local system. For more information, see [Installing Packer](https://www.packer.io/docs/install/index.html) in the Packer documentation. You must also have Alibaba Cloud account credentials configured so that Packer can make calls to Alibaba Cloud API operations on your behalf.

For more information, see [Alibaba Cloud builder](https://www.packer.io/docs/builders/alicloud-ecs.html) in the Packer documentation.

## Building the OS Image

Execute following scripts in your shell

```
export ALICLOUD_REGION=XXX
export ALICLOUD_ACCESS_KEY=XXX
export ALICLOUD_SECRET_KEY=XXX
packer build examples/ack-aliyunlinux2.json
```

## Build ACK-Optimized-OS image

Execute following scripts in your shell

```
export RUNTIME=XXX
export ALICLOUD_REGION=XXX
export ALICLOUD_ACCESS_KEY=XXX
export ALICLOUD_SECRET_KEY=XXX
packer build examples/ack-optimized-os-1.20.json
```
NOTE: `RUNTIME` only support `docker` and `containerd`


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

