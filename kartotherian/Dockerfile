FROM node:10-stretch@sha256:c46b41071ce455e47f205bf83b7ad6593ad22194639df1298a735f407ded1df6

ENV NODE_ENV=production

# Upgrade npm
RUN npm i npm@latest -g \
    && mkdir -p /etc/kartotherian \
    && chown node /etc/kartotherian \
    && chown node /opt

USER node

RUN git clone https://github.com/QwantResearch/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout 100c7acfe46a0f1620f06dd5e77dc65333abbd5e \
    && npm install --production

COPY kartotherian/config.yaml /etc/kartotherian
COPY kartotherian/sources.yaml /etc/kartotherian

ENV KARTOTHERIAN_CASSANDRA_SERVERS=cassandra
ENV KARTOTHERIAN_CASSANDRA_USER=gis
ENV KARTOTHERIAN_CASSANDRA_PSWD=

CMD node /opt/kartotherian/packages/kartotherian/server.js -c /etc/kartotherian/config.yaml
