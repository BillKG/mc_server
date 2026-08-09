#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="/home/ubuntu/mc_hardcore/minecraft"
SCREEN_ID_FILE="${SERVER_DIR}/screen_id.txt"

for other_server in forge vanilla; do
  if screen -ls | grep -qE "\.${other_server}[[:space:]]"; then
    echo "failed:stop ${other_server} before resetting hardcore"
    exit 1
  fi
done

sid=""
if [[ -s "${SCREEN_ID_FILE}" ]]; then
  sid="$(cat "${SCREEN_ID_FILE}")"
else
  sid_full="$(screen -ls | awk '/\.hardcore[[:space:]]/{print $1; exit}')"
  sid="${sid_full%%.*}"
fi

if [[ -n "${sid}" ]] && screen -ls | grep -q "${sid}\."; then
  screen -S "${sid}" -X stuff "/say Hardcore world reset requested. Resetting now.$(printf '\r')"
  screen -S "${sid}" -X stuff "/stop$(printf '\r')"
  for _ in {1..15}; do
    if ! screen -ls | grep -q "${sid}\."; then
      break
    fi
    sleep 1
  done
  screen -S "${sid}" -X quit 2>/dev/null || true
fi

: > "${SCREEN_ID_FILE}"

# Hardcore worlds are intentionally disposable and are never backed up.
rm -rf -- \
  "${SERVER_DIR}/world" \
  "${SERVER_DIR}/world_nether" \
  "${SERVER_DIR}/world_the_end"

start_result="$("${SERVER_DIR}/start_hardcore.sh")"
if [[ "${start_result}" == started:* ]]; then
  echo "reset_started:${start_result#started:}"
  exit 0
fi

echo "${start_result}"
exit 1
