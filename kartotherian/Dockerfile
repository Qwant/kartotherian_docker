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


RUN git clone https://github.com/QwantResearch/kartotherian.git /opt/kartotherian
RUN git clone https://github.com/QwantResearch/kartotherian_config.git /opt/kartotherian_config


RUN cd /opt/kartotherian && npm install --production && npm dedupe

# .xml style is overridden to use system fonts (DejaVu instead of Arial)
COPY omt_osm_bright.xml /opt/kartotherian/node_modules/\@mapbox/mapbox-studio-osm-bright/project.xml

COPY variables.yaml /opt/kartotherian
COPY config.yaml /opt/kartotherian

RUN chmod 600 /opt/kartotherian/variables.yaml

RUN mkdir -p /etc/kartotherian
RUN ln -sf /opt/kartotherian/config.yaml /etc/kartotherian
RUN ln -sf /opt/kartotherian/variables.yaml /etc/kartotherian
RUN ln -sf /opt/kartotherian_config/kartotherian/sources.yaml /etc/kartotherian

COPY cassandra.wait .
RUN chmod +x cassandra.wait

CMD ./cassandra.wait && /usr/bin/nodejs /opt/kartotherian/server.js -c /etc/kartotherian/config.yaml
