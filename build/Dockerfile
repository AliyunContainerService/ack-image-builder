FROM alpine:3.10

ADD  https://releases.hashicorp.com/packer/1.6.0/packer_1.6.0_linux_amd64.zip /packer_1.6.0_linux_amd64.zip
RUN  unzip  packer_1.6.0_linux_amd64.zip && mv packer /bin/packer
COPY examples/ack-kubernetes.json  examples/ack-kubernetes.json
COPY scripts/init.sh  scripts/init.sh

ENTRYPOINT  ["packer", "build"]