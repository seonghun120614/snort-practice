FROM ubuntu:24.04

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y snort tcpdump && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /etc/snort/rules && \
    mkdir -p /etc/snort/rules

CMD ["/bin/bash"]

EXPOSE 1234