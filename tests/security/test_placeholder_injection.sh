#!/bin/sh
set -eu

TEST_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
REPO_DIR=$(CDPATH='' cd -- "${TEST_DIR}/../.." && pwd)

failures=0

log_failure()
{
  printf '%s\n' "${1}" >&2
  return 1
}

init_uac_env()
{
  TEST_ROOT="${1}"

  __UAC_DIR="${REPO_DIR}"
  __UAC_TEMP_DATA_DIR="${TEST_ROOT}/uac-temp"
  __UAC_ARTIFACTS_OUTPUT_DIR="${TEST_ROOT}/collected"
  __UAC_LOG_FILE="uac.log"
  __UAC_VERBOSE_MODE=false
  __UAC_DEBUG_MODE=false
  __UAC_VERBOSE_CMD_PREFIX=" > "
  __UAC_MAX_FILENAME_SIZE=118
  __UAC_OPERATING_SYSTEM="linux"
  __UAC_IGNORE_OPERATING_SYSTEM=false
  __UAC_EXCLUDE_MOUNT_POINTS=""
  __UAC_START_DATE=""
  __UAC_START_DATE_EPOCH=""
  __UAC_END_DATE=""
  __UAC_END_DATE_EPOCH=""
  __UAC_START_DATE_DAYS=0
  __UAC_END_DATE_DAYS=0
  __UAC_CONF_MAX_DEPTH=0
  __UAC_CONF_EXCLUDE_PATH_PATTERN=""
  __UAC_CONF_EXCLUDE_NAME_PATTERN=""
  __UAC_CONF_ENABLE_FIND_MTIME=false
  __UAC_CONF_ENABLE_FIND_CTIME=false
  __UAC_CONF_ENABLE_FIND_ATIME=false
  __UAC_TOOL_FIND_MAXDEPTH_SUPPORT=false
  __UAC_TOOL_FIND_OPERATORS_SUPPORT=false
  __UAC_TOOL_FIND_PATH_SUPPORT=false
  __UAC_TOOL_FIND_PRUNE_SUPPORT=false
  __UAC_TOOL_FIND_PRINT0_SUPPORT=false
  __UAC_TOOL_FIND_TYPE_SUPPORT=false
  __UAC_TOOL_FIND_SIZE_SUPPORT=false
  __UAC_TOOL_FIND_NOGROUP_SUPPORT=false
  __UAC_TOOL_FIND_NOUSER_SUPPORT=false
  __UAC_TOOL_FIND_MTIME_SUPPORT=false
  __UAC_TOOL_FIND_CTIME_SUPPORT=false
  __UAC_TOOL_FIND_ATIME_SUPPORT=false

  mkdir -p "${__UAC_TEMP_DATA_DIR}/tmp" "${__UAC_ARTIFACTS_OUTPUT_DIR}"
  : >"${__UAC_TEMP_DATA_DIR}/${__UAC_LOG_FILE}"

  # shellcheck source=/dev/null
  . "${REPO_DIR}/lib/load_libraries.sh"
}

run_line_placeholder_test()
(
  TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/uac-line-placeholder-XXXXXX")
  trap 'rm -rf "${TEST_ROOT}"' EXIT HUP INT TERM

  init_uac_env "${TEST_ROOT}"

  EVIDENCE_DIR="${TEST_ROOT}/evidence"
  OUTPUT_DIR="${TEST_ROOT}/output"
  mkdir -p "${EVIDENCE_DIR}"
  touch "${EVIDENCE_DIR}/\$(touch\${IFS}LINE_COMMAND_EXECUTED)"

  _command_collector \
    "ls -1 \"${EVIDENCE_DIR}\"" \
    "echo \"%line%\"" \
    "${OUTPUT_DIR}" \
    "" \
    false \
    false \
    >/dev/null

  if [ -f "${OUTPUT_DIR}/LINE_COMMAND_EXECUTED" ]; then
    log_failure "%line% payload executed a shell command"
  fi
)

run_user_placeholder_test()
(
  TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/uac-user-placeholder-XXXXXX")
  trap 'rm -rf "${TEST_ROOT}"' EXIT HUP INT TERM

  init_uac_env "${TEST_ROOT}"

  MOUNT_DIR="${TEST_ROOT}/mount"
  ARTIFACT_FILE="${TEST_ROOT}/artifact.yaml"
  MARKER_DIR="${__UAC_TEMP_DATA_DIR}/tmp/user"
  mkdir -p "${MOUNT_DIR}/etc" "${MOUNT_DIR}/home/evil"

  cat >"${MOUNT_DIR}/etc/passwd" <<'PASSWD'
root:x:0:0:root:/root:/bin/bash
evil$(touch${IFS}USER_COMMAND_EXECUTED):x:1000:1000:evil:/home/evil:/bin/bash
PASSWD

  cat >"${ARTIFACT_FILE}" <<'ART'
artifacts:
-
  description: regression test for %user%
  supported_os: [all]
  collector: command
  command: echo "%user%"
  output_directory: %temp_directory%/user
ART

  __UAC_MOUNT_POINT="${MOUNT_DIR}"
  __UAC_USER_HOME_LIST=$(_get_user_home_list false "${__UAC_MOUNT_POINT}")
  __UAC_VALID_SHELL_ONLY_USER_HOME_LIST="${__UAC_USER_HOME_LIST}"

  _parse_artifact "${ARTIFACT_FILE}" >/dev/null

  if [ -f "${MARKER_DIR}/USER_COMMAND_EXECUTED" ]; then
    log_failure "%user% payload executed a shell command"
  fi
)

run_user_home_placeholder_test()
(
  TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/uac-user-home-placeholder-XXXXXX")
  trap 'rm -rf "${TEST_ROOT}"' EXIT HUP INT TERM

  init_uac_env "${TEST_ROOT}"

  MOUNT_DIR="${TEST_ROOT}/mount"
  ARTIFACT_FILE="${TEST_ROOT}/artifact.yaml"
  MARKER_PATH="${__UAC_TEMP_DATA_DIR}/tmp/user-home/USER_HOME_COMMAND_EXECUTED"
  mkdir -p "${MOUNT_DIR}/etc" "${MOUNT_DIR}/home/evil"

  {
    printf '%s\n' 'root:x:0:0:root:/root:/bin/bash'
    # shellcheck disable=SC2016
    printf 'gooduser:x:1000:1000:evil:/home/evil$(touch${IFS}%s):/bin/bash\n' "${MARKER_PATH}"
  } >"${MOUNT_DIR}/etc/passwd"

  cat >"${ARTIFACT_FILE}" <<'ART'
artifacts:
-
  description: regression test for %user_home%
  supported_os: [all]
  collector: command
  command: echo "%user_home%"
  output_directory: %temp_directory%/user-home
ART

  __UAC_MOUNT_POINT="${MOUNT_DIR}"
  __UAC_USER_HOME_LIST=$(_get_user_home_list false "${__UAC_MOUNT_POINT}")
  __UAC_VALID_SHELL_ONLY_USER_HOME_LIST="${__UAC_USER_HOME_LIST}"

  _parse_artifact "${ARTIFACT_FILE}" >/dev/null

  if [ -f "${MARKER_PATH}" ]; then
    log_failure "%user_home% payload executed a shell command"
  fi
)

run_user_home_path_test()
(
  TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/uac-user-home-path-XXXXXX")
  trap 'rm -rf "${TEST_ROOT}"' EXIT HUP INT TERM

  init_uac_env "${TEST_ROOT}"

  MOUNT_DIR="${TEST_ROOT}/mount"
  ARTIFACT_FILE="${TEST_ROOT}/artifact.yaml"
  MARKER_PATH="${TEST_ROOT}/USER_HOME_PATH_EXECUTED"
  mkdir -p "${MOUNT_DIR}/etc" "${MOUNT_DIR}/home/evil"

  {
    printf '%s\n' 'root:x:0:0:root:/root:/bin/bash'
    # shellcheck disable=SC2016
    printf 'gooduser:x:1000:1000:evil:/home/evil$(touch${IFS}%s):/bin/bash\n' "${MARKER_PATH}"
  } >"${MOUNT_DIR}/etc/passwd"

  cat >"${ARTIFACT_FILE}" <<'ART'
artifacts:
-
  description: regression test for %user_home% in path
  supported_os: [all]
  collector: file
  path: /%user_home%
  output_directory: %temp_directory%/user-home-path
ART

  __UAC_MOUNT_POINT="${MOUNT_DIR}"
  __UAC_USER_HOME_LIST=$(_get_user_home_list false "${__UAC_MOUNT_POINT}")
  __UAC_VALID_SHELL_ONLY_USER_HOME_LIST="${__UAC_USER_HOME_LIST}"

  _parse_artifact "${ARTIFACT_FILE}" >/dev/null

  if [ -f "${MARKER_PATH}" ]; then
    log_failure "%user_home% payload executed a shell command"
  fi
)

run_test()
{
  TEST_NAME="${1}"
  shift

  if "$@"; then
    printf 'ok - %s\n' "${TEST_NAME}"
  else
    printf 'not ok - %s\n' "${TEST_NAME}" >&2
    failures=$((failures + 1))
  fi
}

run_test "%line% is escaped before eval" run_line_placeholder_test
run_test "%user% is escaped before eval" run_user_placeholder_test
run_test "%user_home% is escaped before eval" run_user_home_placeholder_test
run_test "%user_home% path is escaped before eval" run_user_home_path_test

if [ "${failures}" -gt 0 ]; then
  printf 'FAILED: %s regression test(s) failed\n' "${failures}" >&2
  exit 1
fi

printf 'PASS: placeholder injection regressions are covered\n'
