FROM ubuntu:16.04

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
             postgis && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs


RUN git clone https://bitbucket.org/qmap/demultiplexer.git /opt/demultiplexer

RUN git clone https://bitbucket.org/qmap/osm-bright.tm2source.git /opt/osm-bright.tm2source 

RUN git clone https://bitbucket.org/qmap/tilerator.git /opt/tilerator


RUN cd /opt/tilerator && npm install --production && npm dedupe

COPY variables.yaml /opt/tilerator
COPY sources.yaml /opt/tilerator
COPY config.yaml /opt/tilerator


RUN chmod 600 /opt/tilerator/variables.yaml

RUN mkdir -p /etc/tilerator
RUN ln -sf /opt/tilerator/config.yaml /etc/tilerator
RUN ln -sf /opt/tilerator/variables.yaml /etc/tilerator
RUN ln -sf /opt/tilerator/sources.yaml /etc/tilerator

RUN ln -sf /opt/tilerator/dist/init-scripts/cassandra.wait /usr/local/bin

RUN cd /opt/tilerator

RUN cat /opt/tilerator/config.yaml

CMD /usr/local/bin/cassandra.wait && \
   /usr/bin/nodejs /opt/tilerator/server.js -c /etc/tilerator/config.yaml

# ENTRYPOINT ["/bin/sh", "-c", "while true; do sleep 1; done"]
