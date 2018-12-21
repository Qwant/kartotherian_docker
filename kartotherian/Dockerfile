FROM node:6-stretch@sha256:9b5d8caed98111c7bcacd8c46bce19635670b04d59dba20f765b096d6ef98dea

ENV NODE_ENV=production

# Upgrade npm
RUN yarn global add npm \
    && mkdir -p /etc/kartotherian \
    && chown node /etc/kartotherian \
    && chown node /opt

USER node

RUN git clone https://github.com/QwantResearch/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout 832d99f14a8876fce07063ed63257f50a60014b0 \
    && npm install --production \
    && git clone https://github.com/QwantResearch/kartotherian_config.git /opt/kartotherian_config \
    && cd /opt/kartotherian_config \
    && git checkout ff64c9744b8c27e9c7aaaeed919cf0913951fd27

COPY --chown=node variables.yaml /opt/kartotherian
COPY --chown=node config.yaml /opt/kartotherian

RUN chmod 600 /opt/kartotherian/variables.yaml \
    && mkdir -p /etc/kartotherian\
    && ln -sf /opt/kartotherian/config.yaml /etc/kartotherian\
    && ln -sf /opt/kartotherian/variables.yaml /etc/kartotherian\
    && ln -sf /opt/kartotherian_config/kartotherian/sources.yaml /etc/kartotherian

CMD node /opt/kartotherian/server.js -c /etc/kartotherian/config.yaml
