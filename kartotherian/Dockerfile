FROM node:8-stretch@sha256:fec2d6c325686988c4e0bf1b17cd32954422333d24ed6a97c28c8570054a6e1d

ENV NODE_ENV=production

# Upgrade npm
RUN npm i npm@latest -g \
    && mkdir -p /etc/kartotherian \
    && chown node /etc/kartotherian \
    && chown node /opt

USER node

RUN git clone https://github.com/QwantResearch/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout b932ee3254e72aeea6af5935fd53e4269807a86c \
    && npm install --production

COPY kartotherian/config.yaml /etc/kartotherian
COPY kartotherian/sources.yaml /etc/kartotherian

ENV KARTOTHERIAN_CASSANDRA_SERVERS=cassandra
ENV KARTOTHERIAN_CASSANDRA_USER=gis
ENV KARTOTHERIAN_CASSANDRA_PSWD=

CMD node /opt/kartotherian/packages/kartotherian/server.js -c /etc/kartotherian/config.yaml
