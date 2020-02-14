This is the template for ack base image to fix issue [#19](https://github.com/AliyunContainerService/ack-image-builder/issues/19)

Commands to build image:
```
export ALICLOUD_ACCESS_KEY=XXX
export ALICLOUD_SECRET_KEY=XXX
packer build ack-centos-issue-19.json
```