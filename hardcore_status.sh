#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="/home/ubuntu/mc_hardcore/minecraft"
SCREEN_ID_FILE="${SERVER_DIR}/screen_id.txt"

if [[ ! -s "${SCREEN_ID_FILE}" ]]; then
  sid_full="$(screen -ls 2>/dev/null | awk '/\.hardcore[[:space:]]/{print $1; exit}' || true)"
  sid="${sid_full%%.*}"
  if [[ -n "${sid}" ]]; then
    echo "${sid}" > "${SCREEN_ID_FILE}"
    echo "running:${sid}"
    exit 0
  fi
  echo "stopped"
  exit 0
fi

sid="$(cat "${SCREEN_ID_FILE}")"
if screen -ls | grep -q "${sid}\."; then
  echo "running:${sid}"
  exit 0
fi

echo "stopped"
exit 0
