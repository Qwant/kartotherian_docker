FROM node:14-buster-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
        python3-pip \
        locales \
        python3.6 \
        build-essential \
    && apt-get clean \
    && npm i npm@latest -g

RUN git clone https://github.com/Qwant/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout 46dedb6d0c46d0f1dbf6ad4e029d676c63fc5eab \
    && npm ci --production

# install openmaptiles-tools
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install git+https://github.com/openmaptiles/openmaptiles-tools@v0.12.0
    
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

ENV TILERATOR_PORT=80
ENV TILERATOR_OSMDB_HOST=postgres
ENV TILERATOR_OSMDB_USER=gis
ENV TILERATOR_OSMDB_PSWD=gis
ENV TILERATOR_CASSANDRA_SERVERS=cassandra
ENV TILERATOR_CASSANDRA_USER=gis
ENV TILERATOR_CASSANDRA_PSWD=
ENV TILERATOR_REDIS_URL=redis://redis:6379

CMD ["/runserver.sh"]
