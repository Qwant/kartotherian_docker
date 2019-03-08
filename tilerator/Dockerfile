FROM node:8-stretch@sha256:fec2d6c325686988c4e0bf1b17cd32954422333d24ed6a97c28c8570054a6e1d

ENV NODE_ENV=production

RUN apt-get update && \
    apt-get install -y \
        git \
        unzip \
        curl \
        libpq-dev \
        libproj-dev \
        liblua5.2-dev \
        libgeos++-dev \
        nmap \
        netcat \
        redis-tools \
    && npm i npm@latest -g

RUN git clone https://github.com/QwantResearch/tilerator.git /opt/tilerator \
    && cd /opt/tilerator \
    && git checkout 64b69c064aae15d474bd61da2c6bc35140f118f8 \
    && npm install --production

RUN git clone https://github.com/QwantResearch/kartotherian_config.git /opt/kartotherian_config \
    && cd /opt/kartotherian_config \
    && git checkout 0af5aba6e6657c8b42842704947108c33934197a

COPY config*.yaml /opt/tilerator/
COPY gen_tiles.sh /gen_tiles.sh

RUN mkdir -p /etc/tilerator
RUN ln -sf /opt/kartotherian_config/tilerator/data_tm2source_base.yml /etc/tilerator
RUN ln -sf /opt/kartotherian_config/tilerator/data_tm2source_poi.yml /etc/tilerator
RUN ln -sf /opt/kartotherian_config/tilerator/data_tm2source_lite.yml /etc/tilerator

RUN chmod +x /gen_tiles.sh \
    && ln -sf /opt/tilerator/config*.yaml /etc/tilerator \
    && ln -sf /opt/kartotherian_config/tilerator/sources.yaml /etc/tilerator \
    && ln -sf /opt/tilerator/dist/init-scripts/cassandra.wait /usr/local/bin

COPY runserver.sh /runserver.sh
RUN chmod +x /runserver.sh

ENV TILERATOR_OSMDB_HOST=postgres
ENV TILERATOR_OSMDB_USER=gis
ENV TILERATOR_OSMDB_PSWD=
ENV TILERATOR_CASSANDRA_SERVERS=cassandra
ENV TILERATOR_CASSANDRA_USER=gis
ENV TILERATOR_CASSANDRA_PSWD=

CMD ["/runserver.sh"]
