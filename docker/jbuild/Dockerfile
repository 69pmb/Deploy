# syntax=docker/dockerfile-upstream:1.10.0-labs
ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH

FROM arm32v7/maven:3.9-eclipse-temurin-17 AS builder

ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_HASH

WORKDIR /tmp/${GITHUB_PROJECT}

ADD https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}.git#${GITHUB_HASH} .

RUN mvn clean package -DskipTests -Dgcf.skip=true -Dmaven.test.skip=true -q

FROM eclipse-temurin:17-jre-jammy

ARG GITHUB_DIR
ARG GITHUB_PROJECT
ARG GITHUB_SHA
ARG BUILD_DATE

LABEL MAINTAINER 69pmb <pmbroca@gmail.com>
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.url="https://github.com/${GITHUB_DIR}/${GITHUB_PROJECT}"
LABEL org.label-schema.vcs-url="https://github.com/69pmb/Deploy"
LABEL org.label-schema.vcs-ref=${GITHUB_SHA}
LABEL org.label-schema.project=${GITHUB_PROJECT}
LABEL org.label-schema.build-date=${BUILD_DATE}

WORKDIR /opt/app

COPY --from=builder /tmp/${GITHUB_PROJECT}/target/*.jar /opt/app/app.jar

USER 10001
CMD ["java", "-jar", "/opt/app/app.jar"]
