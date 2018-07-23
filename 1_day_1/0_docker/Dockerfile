FROM nginx:1.15

RUN \
    apt-get update && \
    apt-get install -y \
        curl

COPY html/index.html /usr/share/nginx/html

