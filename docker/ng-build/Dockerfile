ARG NG_NGINX_VERSION=0.1.1
ARG ANGULAR_VERSION=14
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH
ARG BUILD_DATE

FROM pmb69/ng-cli:${ANGULAR_VERSION} AS builder

ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH

WORKDIR /tmp

RUN git clone -n https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}.git && \
    cd ${GITHUB_PROJECT} && \
    git checkout ${GITHUB_HASH} && \
    npm ci && \
    ng build --configuration production --progress false --extract-licenses=false

FROM pmb69/ng-nginx:${NG_NGINX_VERSION}

# Args
ARG NG_NGINX_VERSION
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH
ARG BUILD_DATE

# Labels
LABEL ng-nginx-version=${NG_NGINX_VERSION}
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="pmb69/ng-nginx"
LABEL org.label-schema.url="https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}"
LABEL org.label-schema.vcs-url="https://github.com/pmb69/Deploy"
LABEL org.label-schema.vcs-ref=$GITHUB_HASH
LABEL org.label-schema.project=$GITHUB_PROJECT
LABEL org.label-schema.build-date=$BUILD_DATE

WORKDIR /usr/share/nginx/html

COPY --from=builder /tmp/${GITHUB_PROJECT}/dist .

RUN if [ -f assets/env.template.js ]; then \
    apk add --update libintl && \
    apk add --virtual build_deps gettext &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps && \
    rm -rf /var/cache/apk/* ; fi

CMD ["/bin/sh",  "-c",  "if [ -f assets/env.template.js ]; then envsubst < assets/env.template.js > assets/env.js ; fi && exec nginx -g 'daemon off;'"]
