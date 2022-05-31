FROM alpine:3.16 AS builder

RUN apk add curl

RUN mkdir -p /build
WORKDIR /build
RUN curl -Lo extension.zip https://github.com/elastic/apm-aws-lambda/releases/download/v1.0.0/v1.0.0-linux-amd64.zip
RUN unzip extension.zip
# Using v3.33.0, because that is the last version to upload the lambda layer zip
# file as a GitHub release artifact. This is a crutch until we have published
# Docker images for the agent.
RUN curl -Lo agent.zip https://github.com/elastic/apm-agent-nodejs/releases/download/v3.33.0/v3.33.0.zip
RUN unzip agent.zip

FROM amazon/aws-lambda-nodejs:16
COPY --from=builder /build/extensions/ /opt/extensions/
COPY --from=builder /build/nodejs/ /opt/nodejs/
COPY package.json index.js ./
CMD [ "index.handler" ]
