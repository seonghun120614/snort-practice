FROM ubuntu:24.04

WORKDIR /app

ENV RULE_PATH=/etc/snort/rules
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y snort tcpdump curl && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /etc/snort/rules && \
    mkdir -p /etc/snort/rules

CMD ["/bin/bash"]

EXPOSE 1234