FROM node:14-buster-slim

RUN apt-get update \
        && DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --quiet --no-install-recommends \
            git python3.6 build-essential \
        && apt-get clean

ENV NODE_ENV=production

# Upgrade npm
RUN npm i npm@latest -g \
    && mkdir -p /etc/kartotherian \
    && chown node /etc/kartotherian \
    && chown node /opt

USER node

RUN git clone https://github.com/Qwant/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout 46dedb6d0c46d0f1dbf6ad4e029d676c63fc5eab \
    && npm ci --production

COPY kartotherian/config.yaml /etc/kartotherian
COPY kartotherian/sources.yaml /etc/kartotherian

ENV KARTOTHERIAN_PORT=6533
ENV KARTOTHERIAN_CASSANDRA_SERVERS=cassandra
ENV KARTOTHERIAN_CASSANDRA_USER=gis
ENV KARTOTHERIAN_CASSANDRA_PSWD=

# Set KARTOTHERIAN_TELEGRAF_HOST to empty string to disable stats metrics reporter
ENV KARTOTHERIAN_TELEGRAF_HOST=telegraf
ENV KARTOTHERIAN_TELEGRAF_PORT=8125


CMD node /opt/kartotherian/packages/kartotherian/server.js -c /etc/kartotherian/config.yaml
