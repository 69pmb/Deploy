ARG NODE_VERSION=16.13.1-alpine3.12

FROM node:${NODE_VERSION}

ARG ANGULAR_VERSION=latest
ARG BUILD_DATE

#reduce logging, disable angular-cli analytics for ci environment
ENV NPM_CONFIG_LOGLEVEL=warn NG_CLI_ANALYTICS=false

WORKDIR /tmp

# Labels
LABEL node-version=${NODE_VERSION}
LABEL angular-version=$ANGULAR_VERSION
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="pmb69/ng-cli"
LABEL org.label-schema.vcs-url="https://github.com/pmb69/Deploy"
LABEL org.label-schema.build-date=${BUILD_DATE}

RUN apk -U upgrade && \
    apk add --no-cache git openssh && \ 
    rm -rf /var/cache/apk/* && \
    npm i -g @angular/cli@${ANGULAR_VERSION} && \
    npm cache clean --force

# Replaces default node entrypoint to allow/force "ng" command by default
COPY docker-entrypoint.sh /usr/local/bin/

CMD [ "ng" ]
