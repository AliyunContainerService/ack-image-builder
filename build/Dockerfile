FROM alpine:3.23.4

ADD  https://releases.hashicorp.com/packer/1.15.1/packer_1.15.1_linux_amd64.zip /packer_1.15.1_linux_amd64.zip
ADD ./scripts /scripts
ADD ./config /config
RUN  unzip  packer_1.15.1_linux_amd64.zip && mv packer /bin/packer
RUN packer plugins install github.com/hashicorp/alicloud v1.1.2

ENTRYPOINT  ["packer", "build"]