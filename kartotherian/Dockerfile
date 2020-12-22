FROM node:10-stretch@sha256:c46b41071ce455e47f205bf83b7ad6593ad22194639df1298a735f407ded1df6

ENV NODE_ENV=production

# Upgrade npm
RUN npm i npm@latest -g \
    && mkdir -p /etc/kartotherian \
    && chown node /etc/kartotherian \
    && chown node /opt

USER node

RUN git clone https://github.com/Qwant/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout 8ab9f2c2b1493420e8a892f7172c556bec09f63f \
    && npm install --production

COPY kartotherian/config.yaml /etc/kartotherian
COPY kartotherian/sources.yaml /etc/kartotherian

ENV KARTOTHERIAN_CASSANDRA_SERVERS=cassandra
ENV KARTOTHERIAN_CASSANDRA_USER=gis
ENV KARTOTHERIAN_CASSANDRA_PSWD=

CMD node /opt/kartotherian/packages/kartotherian/server.js -c /etc/kartotherian/config.yaml
