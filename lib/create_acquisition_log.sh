# Copyright (C) 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################
# Create the acquisition log.
# Globals:
#   MOUNT_POINT
#   OPERATING_SYSTEM
#   SYSTEM_ARCH
#   UAC_VERSION
# Requires:
#   None
# Arguments:
#   $1: case number
#   $2: evidence number
#   $3: description
#   $4: examiner name
#   $5: notes
#   $6: hostname
#   $7: acquisition start date
#   $8: acquisition end date
#   $9: output file computed hash
#   $10: destination directory
#   $11: output file
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
create_acquisition_log()
{
  cl_case_number="${1:-}"
  shift
  cl_evidence_number="${1:-}"
  shift
  cl_description="${1:-}"
  shift
  cl_examiner="${1:-}"
  shift
  cl_notes="${1:-}"
  shift
  cl_hostname="${1:-}"
  shift
  cl_acquisition_start_date="${1:-}"
  shift
  cl_acquisition_end_date="${1:-}"
  shift
  cl_output_file_hash="${1:-}"
  shift
  cl_destination_directory="${1:-}"
  shift
  cl_output_file="${1:-}"

  cat >"${cl_destination_directory}/${cl_output_file}" << EOF
Created by UAC (Unix-like Artifacts Collector) ${UAC_VERSION}

[Case Information]
Case Number: ${cl_case_number}
Evidence Number: ${cl_evidence_number}
Description: ${cl_description}
Examiner: ${cl_examiner}
Notes: ${cl_notes}

[System Information]
Operating System: ${OPERATING_SYSTEM}
System Architecture: ${SYSTEM_ARCH}
Hostname: ${cl_hostname}

[Acquisition Information]
Mount Point: ${MOUNT_POINT}
Acquisition started at: ${cl_acquisition_start_date}
Acquisition finished at: ${cl_acquisition_end_date}

[Output File MD5 Computed Hash]
${cl_output_file_hash}
EOF

}