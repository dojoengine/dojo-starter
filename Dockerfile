FROM ghcr.io/dojoengine/dojo:v1.3.1

RUN apt update && apt install curl jq -y