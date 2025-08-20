FROM ghcr.io/dojoengine/dojo:v1.6.0-alpha.1 AS dojo

RUN apt update && apt install curl jq -y

FROM ghcr.io/dojoengine/katana-dev:test AS katana


FROM ghcr.io/dojoengine/torii:v1.6.0-alpha.1 AS torii

RUN apt update && apt install jq -y


