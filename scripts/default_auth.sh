#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

need_cmd() {
  if ! check_cmd "$1"; then
    printf "need '$1' (command not found)"
    exit 1
  fi
}

check_cmd() {
  command -v "$1" &>/dev/null
}

need_cmd jq

export RPC_URL="http://localhost:5050"

export WORLD_ADDRESS=$(cat ./manifests/dev/manifest.json | jq -r '.world.address')

echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS
echo "---------------------------------------------------------------------------"

# enable system -> models authorizations
sozo auth grant --world $WORLD_ADDRESS --wait writer \
  Position,dojo_starter::systems::actions::actions\
  Moves,dojo_starter::systems::actions::actions\
  >/dev/null

echo "Default authorizations have been successfully set."
