#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="/home/ubuntu/mc_hardcore/minecraft"
SCREEN_NAME="hardcore"
SCREEN_ID_FILE="${SERVER_DIR}/screen_id.txt"
LOG_FILE="${SERVER_DIR}/hardcore_start.log"

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

for other_server in forge vanilla; do
  if screen -ls | grep -qE "\.${other_server}[[:space:]]"; then
    echo "failed:stop ${other_server} before starting hardcore"
    exit 1
  fi
done

if ! grep -qx "hardcore=true" "${SERVER_DIR}/server.properties"; then
  echo "failed:server.properties must contain hardcore=true"
  exit 1
fi

if ! grep -qx "server-port=25566" "${SERVER_DIR}/server.properties"; then
  echo "failed:server.properties must contain server-port=25566"
  exit 1
fi

screen -L -Logfile "${LOG_FILE}" -dmS "${SCREEN_NAME}" bash -lc "cd ${SERVER_DIR} && sudo -n ${SERVER_DIR}/java -Xmx6096M -Xms6096M -jar server.jar nogui"

sid_full=""
for _ in {1..5}; do
  sleep 2
  sid_full="$(screen -ls | awk '/\.hardcore[[:space:]]/{print $1; exit}')"
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
