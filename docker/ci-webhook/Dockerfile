FROM thecatlady/webhook:2.8.1

RUN apk add --update --no-cache bash git docker docker-cli-compose

COPY deploy.sh hooks.yml /config/

RUN chmod +x /config/deploy.sh
