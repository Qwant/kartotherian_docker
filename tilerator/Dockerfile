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
        python3.5 \
        python3-pip \
        locales \
    && npm i npm@latest -g

RUN git clone https://github.com/QwantResearch/tilerator.git /opt/tilerator \
    && cd /opt/tilerator \
    && git checkout 64b69c064aae15d474bd61da2c6bc35140f118f8 \
    && npm install --production

# install openmaptiles-tools
RUN python3.5 -m pip install --upgrade pip \
    && python3.5 -m pip install openmaptiles-tools
# install openmaptiles
COPY openmaptiles /opt/openmaptiles
# setup needed directories
RUN mkdir -p /opt/config/imposm
RUN mkdir -p /opt/config/tilerator
# needed for sql script, else the BOM in the file makes the query impossible
RUN locale-gen en_US.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL C.UTF-8
# generate config files
RUN cd /opt/openmaptiles \
    && CONFIG_DIR=/opt/config make qwant

COPY tilerator/config*.yaml /opt/tilerator/
COPY tilerator/sources.yaml /opt/tilerator/
COPY tilerator/gen_tiles.sh /gen_tiles.sh

RUN mkdir -p /etc/tilerator
RUN ln -sf /opt/config/tilerator/data_tm2source_base.yml /etc/tilerator
RUN ln -sf /opt/config/tilerator/data_tm2source_poi.yml /etc/tilerator
RUN ln -sf /opt/config/tilerator/data_tm2source_lite.yml /etc/tilerator

RUN chmod +x /gen_tiles.sh \
    && ln -sf /opt/tilerator/config*.yaml /etc/tilerator \
    && ln -sf /opt/tilerator/dist/init-scripts/cassandra.wait /usr/local/bin

COPY tilerator/runserver.sh /runserver.sh
RUN chmod +x /runserver.sh

ENV TILERATOR_OSMDB_HOST=postgres
ENV TILERATOR_OSMDB_USER=gis
ENV TILERATOR_OSMDB_PSWD=
ENV TILERATOR_CASSANDRA_SERVERS=cassandra
ENV TILERATOR_CASSANDRA_USER=gis
ENV TILERATOR_CASSANDRA_PSWD=

CMD ["/runserver.sh"]
