FROM ghcr.io/dojoengine/dojo:v1.2.1

RUN apt update && apt install curl jq -y