FROM thecatlady/webhook:2.8.0

RUN apk add --update --no-cache bash jq git docker docker-cli-compose

COPY deploy.sh hooks.yml /config/

RUN chmod +x /config/deploy.sh
