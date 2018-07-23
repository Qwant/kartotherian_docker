#!/bin/bash
set -e
set -x

apt-get update && apt-get install -y \
    git \
    unzip \
    screen \
    curl \
    libpq-dev \
    libproj-dev \
    liblua5.2-dev \
    libgeos++-dev \
    osmctools \
    nmap \
    sqlite3 \
    gdal-bin \
    postgis \
    osmosis \
    jq \
    redis-tools

# install imposm
wget https://github.com/omniscale/imposm3/releases/download/v0.6.0-alpha.4/imposm-0.6.0-alpha.4-linux-x86-64.tar.gz \
    && tar xvfz imposm-0.6.0-alpha.4-linux-x86-64.tar.gz \
    && ln -sf /imposm-0.6.0-alpha.4-linux-x86-64/imposm3 /usr/local/bin/imposm3 \
    && wget -O /usr/local/bin/pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.1/pgfutter_linux_amd64 \
    && chmod +x /usr/local/bin/pgfutter
