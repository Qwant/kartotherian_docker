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
    && git checkout 98338d934057426fb3ac938b0e00c6dee533efc3 \
    && npm install --production \
    && git clone https://github.com/QwantResearch/kartotherian_config.git /opt/kartotherian_config \
    && cd /opt/kartotherian_config \
    && git checkout 78208ef48b925c1e81fdad4dd47227b3d31f7fe1

COPY --chown=node config.yaml /opt/kartotherian

RUN mkdir -p /etc/kartotherian\
    && ln -sf /opt/kartotherian/config.yaml /etc/kartotherian\
    && ln -sf /opt/kartotherian_config/kartotherian/sources.yaml /etc/kartotherian

ENV KARTOTHERIAN_CASSANDRA_SERVERS=cassandra
ENV KARTOTHERIAN_CASSANDRA_USER=gis
ENV KARTOTHERIAN_CASSANDRA_PSWD=

CMD node /opt/kartotherian/server.js -c /etc/kartotherian/config.yaml
