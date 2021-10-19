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
# Print acquisition log.
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
# Outputs:
#   Write acquisition log to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
print_acquisition_log()
{
  pl_case_number="${1:-}"
  shift
  pl_evidence_number="${1:-}"
  shift
  pl_description="${1:-}"
  shift
  pl_examiner="${1:-}"
  shift
  pl_notes="${1:-}"
  shift
  pl_hostname="${1:-}"
  shift
  pl_acquisition_start_date="${1:-}"
  shift
  pl_acquisition_end_date="${1:-}"
  shift
  pl_output_file_hash="${1:-}"

  printf %b "Created by UAC (Unix-like Artifacts Collector) v${UAC_VERSION}\n\n"
  
  printf %b "[Case Information]\n"
  printf %b "Case Number: ${pl_case_number}\n"
  printf %b "Evidence Number: ${pl_evidence_number}\n"
  printf %b "Description: ${pl_description}\n"
  printf %b "Examiner: ${pl_examiner}\n"
  printf %b "Notes: ${pl_notes}\n\n"
  
  printf %b "[System Information]\n"
  printf %b "Operating System: ${OPERATING_SYSTEM}\n"
  printf %b "System Architecture: ${SYSTEM_ARCH}\n"
  printf %b "Hostname: ${pl_hostname}\n\n"
  
  printf %b "[Acquisition Information]\n"
  printf %b "Mount Point: ${MOUNT_POINT}\n"
  printf %b "Acquisition started at: ${pl_acquisition_start_date}\n"
  printf %b "Acquisition finished at: ${pl_acquisition_end_date}\n\n"

  printf %b "[Output File MD5 Computed Hash]\n"
  printf %b "${pl_output_file_hash}\n\n"

}