FROM node:14-stretch

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

ENV KARTOTHERIAN_CASSANDRA_SERVERS=cassandra
ENV KARTOTHERIAN_CASSANDRA_USER=gis
ENV KARTOTHERIAN_CASSANDRA_PSWD=

CMD node /opt/kartotherian/packages/kartotherian/server.js -c /etc/kartotherian/config.yaml
