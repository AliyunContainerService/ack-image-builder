# Image Build Specification of Alibaba Cloud Container Service for Kubernetes (ACK) 

This repository contains resources and configuration scripts for building a custom base OS Image for ACK with [HashiCorp Packer](https://www.packer.io/).

## Setup

You must have [Packer](https://www.packer.io/) installed on your local system. For more information, see [Installing Packer](https://www.packer.io/docs/install/index.html) in the Packer documentation. You must also have Alibaba Cloud account credentials configured so that Packer can make calls to Alibaba Cloud API operations on your behalf.

For more information, see [Alibaba Cloud builder](https://www.packer.io/docs/builders/alicloud-ecs.html) in the Packer documentation.

## Building the OS Image

Execute following scripts in your shell

```
export ALICLOUD_ACCESS_KEY=XXX
export ALICLOUD_SECRET_KEY=XXX
packer build ack-centos.json
```

## Security

For security issues or concerns, please do not open an issue or pull request on GitHub. Please report any suspected or confirmed security issues to Alibaba Cloud Container Security contact <kubernetes-security@service.aliyun.com>

