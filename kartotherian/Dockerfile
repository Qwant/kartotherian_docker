FROM node:6-stretch

ENV NODE_ENV=production

# Upgrade npm
RUN curl -sL https://www.npmjs.org/install.sh | sh

RUN mkdir -p /etc/kartotherian
RUN chown node /etc/kartotherian
RUN chown node /opt

USER node

RUN git clone https://github.com/QwantResearch/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout c4fc56843f \
    && npm install --production \
    && git clone https://github.com/QwantResearch/kartotherian_config.git /opt/kartotherian_config \
    && cd /opt/kartotherian_config \
    && git checkout 6b5f4c1881da1c553157cc3fbaf4916b3ba58dcb

COPY --chown=node variables.yaml /opt/kartotherian
COPY --chown=node config.yaml /opt/kartotherian

RUN chmod 600 /opt/kartotherian/variables.yaml

RUN mkdir -p /etc/kartotherian\
    && ln -sf /opt/kartotherian/config.yaml /etc/kartotherian\
    && ln -sf /opt/kartotherian/variables.yaml /etc/kartotherian\
    && ln -sf /opt/kartotherian_config/kartotherian/sources.yaml /etc/kartotherian

CMD node /opt/kartotherian/server.js -c /etc/kartotherian/config.yaml
