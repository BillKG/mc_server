#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="/home/ubuntu/forge-1.20.1"
SCREEN_NAME="forge"
SCREEN_ID_FILE="${SERVER_DIR}/screen_id.txt"
LOG_FILE="${SERVER_DIR}/forge_start.log"

cd "${SERVER_DIR}"

if ! command -v screen >/dev/null 2>&1; then
  echo "failed:screen not installed"
  exit 1
fi

if [[ -s "${SCREEN_ID_FILE}" ]]; then
  sid="$(cat "${SCREEN_ID_FILE}")"
  if screen -ls | grep -q "${sid}\."; then
    echo "already_running:${sid}"
    exit 0
  fi
fi

screen -L -Logfile "${LOG_FILE}" -dmS "${SCREEN_NAME}" bash -lc "cd ${SERVER_DIR} && ./run.sh"

sid_full=""
for _ in {1..5}; do
  sleep 2
  sid_full="$(screen -ls | awk '/\.forge/{print $1; exit}')"
  if [[ -n "${sid_full}" ]]; then
    break
  fi
done

sid="${sid_full%%.*}"
if [[ -n "${sid}" ]]; then
  echo "${sid}" > "${SCREEN_ID_FILE}"
  echo "started:${sid}"
  exit 0
fi

log_tail="$(tail -n 30 "${LOG_FILE}" 2>/dev/null | tr '\n' ' ')"
echo "failed:${log_tail:-no screen session found}"
exit 1
