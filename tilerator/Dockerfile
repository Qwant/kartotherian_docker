FROM ubuntu:16.04

ENV NODE_PATH='/opt/tilerator/node_modules' \
    TILERATOR_PORT=80

RUN apt update && \
    apt install -y \
             git \
             unzip \
             python-pip \
             screen \
             curl \
             libpq-dev \
             libproj-dev \
             liblua5.2-dev \
             libgeos++-dev \
             osmctools \
             nmap \
             netcat \
             postgis \
             redis-tools \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs

RUN git clone https://github.com/QwantResearch/tilerator.git /opt/tilerator \
    && cd /opt/tilerator \
    && git checkout 0061c45d21 \
    && npm install --production && npm dedupe

RUN git clone https://github.com/QwantResearch/kartotherian_config.git /opt/kartotherian_config \
    && cd /opt/kartotherian_config \
    && git checkout d0e82741a5

COPY variables.yaml /opt/tilerator
COPY config.yaml /opt/tilerator
COPY gen_tiles.sh /gen_tiles.sh

RUN mkdir -p /etc/tilerator
RUN ln -sf /opt/kartotherian_config/tilerator/data_tm2source_base.xml /etc/tilerator
RUN ln -sf /opt/kartotherian_config/tilerator/data_tm2source_poi.xml /etc/tilerator
RUN ln -sf /opt/kartotherian_config/tilerator/data_tm2source_lite.xml /etc/tilerator

RUN chmod +x /gen_tiles.sh \
    && chmod 600 /opt/tilerator/variables.yaml \
    && ln -sf /opt/tilerator/config.yaml /etc/tilerator \
    && ln -sf /opt/tilerator/variables.yaml /etc/tilerator \
    && ln -sf /opt/kartotherian_config/tilerator/sources.yaml /etc/tilerator \
    && ln -sf /opt/tilerator/dist/init-scripts/cassandra.wait /usr/local/bin

COPY runserver.sh /runserver.sh
RUN chmod +x /runserver.sh

CMD ["/runserver.sh"]
