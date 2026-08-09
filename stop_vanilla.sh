#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="/home/ubuntu/mc_vanilla/minecraft"
SCREEN_ID_FILE="${SERVER_DIR}/screen_id.txt"

sid=""
if [[ -s "${SCREEN_ID_FILE}" ]]; then
  sid="$(cat "${SCREEN_ID_FILE}")"
else
  sid_full="$(screen -ls 2>/dev/null | awk '/\.vanilla[[:space:]]/{print $1; exit}' || true)"
  sid="${sid_full%%.*}"
fi

if [[ -n "${sid}" ]] && screen -ls | grep -q "${sid}\."; then
  screen -S "${sid}" -X stuff "/stop$(printf '\r')"
  sleep 5
  screen -S "${sid}" -X quit || true
fi

: > "${SCREEN_ID_FILE}"
echo "stopped"
