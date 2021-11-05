ARG ARM32V7_NGINX_VERSION=1.21.3-alpine

FROM arm32v7/nginx:${ARM32V7_NGINX_VERSION}

LABEL maintainer "69pmb <pmbroca@gmail.com>"
LABEL nginx-version=$NGINX_VERSION

WORKDIR /etc/nginx
COPY conf .

HEALTHCHECK --interval=120s CMD wget --spider -q http://localhost:8080
