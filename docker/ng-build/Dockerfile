ARG NODE_VERSION=16.12.0-alpine3.12
ARG GITHUB_PROJECT

FROM node:${NODE_VERSION} AS build

ARG ANGULAR_VERSION=12
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH

WORKDIR /tmp

RUN apk -U upgrade && \
    apk add --no-cache git openssh && \
    npm i -g @angular/cli@${ANGULAR_VERSION}

RUN git clone -n https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}.git && \
    cd ${GITHUB_PROJECT} && \
    git checkout ${GITHUB_HASH} && \
    npm ci --only=production && \
    npm run build --extract-licenses=false

FROM pmb69/ng-nginx:0.1.0

ARG GITHUB_PROJECT

WORKDIR /usr/share/nginx/html

COPY --from=build /tmp/${GITHUB_PROJECT}/dist .

RUN if [ -f assets/env.template.js ]; then \
    apk add --update libintl && \
    apk add --virtual build_deps gettext &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps && \
    rm -rf /var/cache/apk/* ; fi    

CMD ["/bin/sh",  "-c",  "if [ -f assets/env.template.js ]; then envsubst < assets/env.template.js > assets/env.js ; fi && exec nginx -g 'daemon off;'"]
