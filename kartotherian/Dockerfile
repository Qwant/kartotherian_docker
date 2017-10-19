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
             net-tools \
             libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential g++ \
             postgis && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs


RUN git clone https://bitbucket.org/qmap/demultiplexer.git /opt/demultiplexer

# RUN git clone https://bitbucket.org/qmap/osm-bright.tm2source.git /opt/osm-bright.tm2source 

RUN git clone https://bitbucket.org/qmap/snapshot.git /opt/snapshot
RUN git clone https://bitbucket.org/qmap/kartotherian.git /opt/kartotherian

RUN cd /opt/kartotherian && npm install --production && npm dedupe

RUN cd /opt/kartotherian && \
    npm install git+https://github.com/openmaptiles/mapbox-studio-osm-bright.tm2.git

# .xml style is overridden to use system fonts (DejaVu instead of Arial)
COPY omt_osm_bright.xml /opt/kartotherian/node_modules/\@mapbox/mapbox-studio-osm-bright/project.xml

COPY variables.yaml /opt/kartotherian
COPY sources.yaml /opt/kartotherian
COPY config.yaml /opt/kartotherian

RUN chmod 600 /opt/kartotherian/variables.yaml

RUN mkdir -p /etc/kartotherian
RUN ln -sf /opt/kartotherian/config.yaml /etc/kartotherian
RUN ln -sf /opt/kartotherian/variables.yaml /etc/kartotherian
RUN ln -sf /opt/kartotherian/sources.yaml /etc/kartotherian

RUN ln -sf /opt/kartotherian/dist/init-scripts/cassandra.wait /usr/local/bin

CMD /usr/bin/nodejs /opt/kartotherian/server.js -c /etc/kartotherian/config.yaml

# ENTRYPOINT ["/bin/sh", "-c", "while true; do sleep 1; done"]