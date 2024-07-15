#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Create the acquisition log.
# Arguments:
#   string file: full path to the acquisition file
#   string start_date: acquisition start date
#   string end_date: acquisition end date
#   string computed_hashes: computed hashes
# Returns:
#   none
_create_acquisition_log()
{
  __cl_file="${1:-}"
  __cl_start_date="${2:-}"
  __cl_end_date="${3:-}"
  __cl_output_file_md5_hash="${4:-}"
  __cl_output_file_sha1_hash="${5:-}"
  __cl_output_file_sha256_hash="${6:-}"

  cat >"${__cl_file}" << EOF
Created by UAC (Unix-like Artifacts Collector) ${__UAC_VERSION}

[Case Information]
Case Number: ${__UAC_CASE_NUMBER}
Evidence Number: ${__UAC_EVIDENCE_NUMBER}
Description: ${__UAC_EVIDENCE_DESCRIPTION}
Examiner: ${__UAC_EXAMINER}
Notes: ${__UAC_EVIDENCE_NOTES}

[System Information]
Operating System: ${__UAC_OPERATING_SYSTEM}
System Architecture: ${__UAC_SYSTEM_ARCH}
Hostname: ${__UAC_HOSTNAME}

[Acquisition Information]
Mount Point: ${__UAC_MOUNT_POINT}
Acquisition Started: ${__cl_start_date}
Acquisition Finished: ${__cl_end_date}

[Output Information]
EOF

if [ "${__UAC_OUTPUT_FORMAT}" = "none" ]; then
  cat >>"${__cl_file}" << EOF
Directory: ${__UAC_OUTPUT_BASE_NAME}
Format: ${__UAC_OUTPUT_FORMAT}
EOF
else
  cat >>"${__cl_file}" << EOF
File: ${__UAC_OUTPUT_BASE_NAME}.${__UAC_OUTPUT_EXTENSION}
Format: ${__UAC_OUTPUT_FORMAT}
EOF
  if [ "${__UAC_OUTPUT_FORMAT}" = "zip" ] && [ -n "${__UAC_OUTPUT_PASSWORD}" ]; then
    cat >>"${__cl_file}" << EOF
Password: "${__UAC_OUTPUT_PASSWORD}"
EOF
  fi

  cat >>"${__cl_file}" << EOF

[Computed Hashes]
EOF

  if [ -n "${__cl_output_file_md5_hash}" ]; then
    printf "MD5 checksum: %s\n" "${__cl_output_file_md5_hash}" >>"${__cl_file}"
  fi
  if [ -n "${__cl_output_file_sha1_hash}" ]; then
    printf "SHA1 checksum: %s\n" "${__cl_output_file_sha1_hash}" >>"${__cl_file}"
  fi
  if [ -n "${__cl_output_file_sha256_hash}" ]; then
    printf "SHA256 checksum: %s\n" "${__cl_output_file_sha256_hash}" >>"${__cl_file}"
  fi

fi

}