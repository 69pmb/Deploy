# syntax=docker/dockerfile-upstream:master-labs
ARG NODE_VERSION=16.13.1-alpine3.12
ARG NG_NGINX_VERSION=latest
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH

FROM node:${NODE_VERSION} AS builder

ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH

WORKDIR /tmp/${GITHUB_PROJECT}

ADD https://raw.githubusercontent.com/${GITHUB_DIR}/${GITHUB_PROJECT}/${GITHUB_HASH}/package.json .
ADD https://raw.githubusercontent.com/${GITHUB_DIR}/${GITHUB_PROJECT}/${GITHUB_HASH}/package-lock.json .

RUN npm ci --ignore-scripts

ADD https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}.git#${GITHUB_HASH} .

RUN npx ng build --configuration production --progress false --extract-licenses=false

FROM pmb69/ng-nginx:${NG_NGINX_VERSION}

# Args
ARG NODE_VERSION
ARG NG_NGINX_VERSION
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH
ARG BUILD_DATE
ARG ENV_VAR

# Labels
LABEL node-version=${NODE_VERSION}
LABEL ng-nginx-version=${NG_NGINX_VERSION}
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="pmb69/ng-nginx"
LABEL org.label-schema.url="https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}"
LABEL org.label-schema.vcs-url="https://github.com/69pmb/Deploy"
LABEL org.label-schema.vcs-ref=$GITHUB_HASH
LABEL org.label-schema.project=$GITHUB_PROJECT
LABEL org.label-schema.build-date=$BUILD_DATE

WORKDIR /usr/share/nginx/html

COPY --from=builder /tmp/${GITHUB_PROJECT}/dist .

RUN if [ $ENV_VAR ]; then \
    cat assets/configuration.json | sed "s/{{/$/" | sed "s/}}//" > assets/configuration.json && \
    apk add --update libintl && \
    apk add --virtual build_deps gettext && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps && \
    rm -rf /var/cache/apk/* ; fi

CMD ["/bin/sh",  "-c",  "if [ $ENV_VAR ]; then conf=$(envsubst < assets/configuration.json); echo $conf > assets/configuration.json; fi && exec nginx -g 'daemon off;'"]
