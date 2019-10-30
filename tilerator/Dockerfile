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

RUN git clone https://github.com/QwantResearch/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout b932ee3254e72aeea6af5935fd53e4269807a86c \
    && npm install --production

# install openmaptiles-tools
RUN python3.5 -m pip install --upgrade pip \
    && python3.5 -m pip install openmaptiles-tools==0.9.2
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

RUN mkdir -p /etc/tilerator
COPY tilerator/config*.yaml /etc/tilerator/
COPY tilerator/gen_tiles.sh /gen_tiles.sh

COPY tilerator/sources.yaml /etc/tilerator/
RUN ln -sf /opt/config/tilerator/data_tm2source_base.yml /etc/tilerator
RUN ln -sf /opt/config/tilerator/data_tm2source_poi.yml /etc/tilerator
RUN ln -sf /opt/config/tilerator/data_tm2source_lite.yml /etc/tilerator

RUN chmod +x /gen_tiles.sh

COPY tilerator/runserver.sh /runserver.sh
RUN chmod +x /runserver.sh

ENV TILERATOR_OSMDB_HOST=postgres
ENV TILERATOR_OSMDB_USER=gis
ENV TILERATOR_OSMDB_PSWD=
ENV TILERATOR_CASSANDRA_SERVERS=cassandra
ENV TILERATOR_CASSANDRA_USER=gis
ENV TILERATOR_CASSANDRA_PSWD=

CMD ["/runserver.sh"]
