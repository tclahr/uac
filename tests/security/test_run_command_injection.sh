#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

set -eu

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
UAC_DIR=$(cd "${TEST_DIR}/../.." && pwd)
WORK_DIR="${TEST_DIR}/work/run-command-injection"
MARKER_FILE="${WORK_DIR}/COMMAND_EXECUTED"

rm -rf "${WORK_DIR}"
trap 'rm -rf "${WORK_DIR}"; rmdir "${TEST_DIR}/work" >/dev/null 2>/dev/null || true' EXIT
mkdir -p "${WORK_DIR}/uac-temp"

__UAC_DIR="${UAC_DIR}"
__UAC_TEMP_DATA_DIR="${WORK_DIR}/uac-temp"
__UAC_LOG_FILE="uac.log"
__UAC_VERBOSE_MODE=false
__UAC_DEBUG_MODE=false

: >"${__UAC_TEMP_DATA_DIR}/${__UAC_LOG_FILE}"

# shellcheck disable=SC1091
. "${UAC_DIR}/lib/load_libraries.sh"

# shellcheck disable=SC2016
printf '%s\n' '$(touch${IFS}COMMAND_EXECUTED)' >"${WORK_DIR}/untrusted.txt"
UNTRUSTED=$(cat "${WORK_DIR}/untrusted.txt")

cd "${WORK_DIR}"

if _run_command "echo safe ${UNTRUSTED}" true >/dev/null 2>&1; then
  true
fi

if [ -f "${MARKER_FILE}" ]; then
  echo "FAIL: _run_command executed injected payload and created ${MARKER_FILE}"
  exit 1
fi

echo "PASS: _run_command did not execute injected payload"
