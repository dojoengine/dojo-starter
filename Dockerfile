FROM ghcr.io/dojoengine/dojo:v1.4.0

RUN apt update && apt install curl jq -y