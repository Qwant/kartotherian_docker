FROM node:8-stretch as builder

RUN apt update && apt install -y libstdc++6

RUN cd /opt && git clone https://github.com/QwantResearch/qwant-basic-gl-style.git

WORKDIR /opt/qwant-basic-gl-style

RUN git clone https://github.com/QwantResearch/map-style-builder.git

COPY tileview_conf.json /opt/qwant-basic-gl-style/map-style-builder

RUN cd map-style-builder && npm install && \
	npm run build_all -- --style-dir=../ --conf=./tileview_conf.json



FROM nginx:alpine
COPY --from=builder /opt/qwant-basic-gl-style/build/* /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/
