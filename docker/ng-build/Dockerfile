# syntax=docker/dockerfile-upstream:master-labs
ARG NODE_VERSION=16.20.2-alpine3.18
ARG NG_NGINX_VERSION=latest
ARG PNPM=pnpm
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH

# Copy pnpm lock file
FROM node:${NODE_VERSION} AS builder_pnpm
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH
WORKDIR /tmp/${GITHUB_PROJECT}
ONBUILD ADD https://raw.githubusercontent.com/${GITHUB_DIR}/${GITHUB_PROJECT}/${GITHUB_HASH}/pnpm-lock.yaml .

# Copy npm lock file
FROM node:${NODE_VERSION} AS builder_npm
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH
WORKDIR /tmp/${GITHUB_PROJECT}
ONBUILD ADD https://raw.githubusercontent.com/${GITHUB_DIR}/${GITHUB_PROJECT}/${GITHUB_HASH}/package-lock.json .

FROM builder_${PNPM} AS builder

ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH
ARG PNPM

ADD https://raw.githubusercontent.com/${GITHUB_DIR}/${GITHUB_PROJECT}/${GITHUB_HASH}/package.json .

RUN apk -U upgrade && \
    apk add --no-cache git openssh && \
    if [[ $PNPM == 'pnpm' ]]; then \
    if [[ $(echo "$(node -v | sed 's/v//g' | cut -d. -f1) >= 16" | bc) -eq 1 ]]; then \
    corepack enable && \
    corepack prepare pnpm@latest --activate; else \
    npm install -g pnpm ; fi ; fi

RUN if [[ $PNPM == 'pnpm' ]]; then pnpm i --frozen-lockfile --ignore-scripts; else npm ci --ignore-scripts ; fi

ADD https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}.git#${GITHUB_HASH} .

RUN buildCmd="build --configuration production --progress false --extract-licenses=true" && \
    if [[ $PNPM == 'pnpm']]; then buildCmd="pnpm $buildCmd" ; else buildCmd="npx ng $buildCmd" ; fi && \ 
    eval "$buildCmd" 

FROM pmb69/ng-nginx:${NG_NGINX_VERSION}

# Args
ARG NODE_VERSION
ARG NG_NGINX_VERSION
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_SHA
ARG BUILD_DATE
ARG ENV_VAR

# Labels
LABEL node-version=${NODE_VERSION}
LABEL ng-nginx-version=${NG_NGINX_VERSION}
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="pmb69/ng-nginx"
LABEL org.label-schema.url="https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}"
LABEL org.label-schema.vcs-url="https://github.com/69pmb/Deploy"
LABEL org.label-schema.vcs-ref=${GITHUB_SHA}
LABEL org.label-schema.project=${GITHUB_PROJECT}
LABEL org.label-schema.build-date=${BUILD_DATE}

WORKDIR /usr/share/nginx/html

COPY --from=builder /tmp/${GITHUB_PROJECT}/dist .

RUN rm 3rdpartylicenses.txt

RUN if [ $ENV_VAR ]; then \
    cat assets/configuration.json | sed "s/{{/$/" | sed "s/}}//" > assets/configuration.json && \
    apk add --update libintl && \
    apk add --virtual build_deps gettext && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps && \
    rm -rf /var/cache/apk/* ; fi

CMD ["/bin/sh",  "-c",  "if [ $ENV_VAR ]; then conf=$(envsubst < assets/configuration.json); echo $conf > assets/configuration.json; fi && exec nginx -g 'daemon off;'"]
