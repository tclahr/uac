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
# Get the list of mount points by file system.
# Globals:
#   OPERATING_SYSTEM
# Requires:
#   None
# Arguments:
#   $1: comma separated list of file systems
# Outputs:
#   Write the list of mount points (comma separated) to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_mount_point_by_file_system()
{
  gm_file_system_list="${1:-}"

  # return if file system list is empty
  if [ -z "${gm_file_system_list}" ]; then
    printf %b "get_mount_point_by_file_system: missing required argument: \
'file system list'\n" >&2
    return 2
  fi

  # list mounted points
  # remove white spaces from gm_file_system_list
  # remove double quotes from gm_file_system_list
  # split into an array and record values into a awk dict
  # print if file system is in gm_file_system_dict
  # remove last comma from output
  case "${OPERATING_SYSTEM}" in
    "aix")
      mount \
        | awk -v gm_file_system_list="${gm_file_system_list}" \
          'BEGIN {
            gsub(/[ ]+/, "", gm_file_system_list);
            gsub("\"", "", gm_file_system_list);
            split(gm_file_system_list, gm_file_system_array, ",");
            for (i in gm_file_system_array) {
              gm_file_system_dict[gm_file_system_array[i]]="";
            }
          }
          {
            if ($3 in gm_file_system_dict) {
              printf "%s,", $2;
            }
          }' \
        | awk '{gsub(/,$/, ""); print}' 2>/dev/null
      ;;
    "esxi")
      df -u \
        | awk -v gm_file_system_list="${gm_file_system_list}" \
          'BEGIN {
            gsub(/[ ]+/, "", gm_file_system_list);
            gsub("\"", "", gm_file_system_list);
            split(gm_file_system_list, gm_file_system_array, ",");
            for (i in gm_file_system_array) {
              gm_file_system_dict[gm_file_system_array[i]]="";
            }
          }
          {
            if (tolower($1) in gm_file_system_dict) {
              printf "%s,", $6;
            }
          }' \
        | awk '{gsub(/,$/, ""); print}' 2>/dev/null
      ;;
    "freebsd"|"macos"|"netscaler")
      mount \
        | sed -e 's:(::g' -e 's:,: :g' -e 's:)::g' \
        | awk 'BEGIN { FS=" on "; } { print $2; }' \
        | awk -v gm_file_system_list="${gm_file_system_list}" \
          'BEGIN {
            gsub(/[ ]+/, "", gm_file_system_list);
            gsub("\"", "", gm_file_system_list);
            split(gm_file_system_list, gm_file_system_array, ",");
            for (i in gm_file_system_array) {
              gm_file_system_dict[gm_file_system_array[i]]="";
            }
          }
          {
            if ($2 in gm_file_system_dict) {
              printf "%s,", $1;
            }
          }' \
        | awk '{gsub(/,$/, ""); print}' 2>/dev/null
      ;;
    "android"|"linux"|"netbsd"|"openbsd")
      mount \
        | awk 'BEGIN { FS=" on "; } { print $2; }' \
        | awk -v gm_file_system_list="${gm_file_system_list}" \
          'BEGIN {
            gsub(/[ ]+/, "", gm_file_system_list);
            gsub("\"", "", gm_file_system_list);
            split(gm_file_system_list, gm_file_system_array, ",");
            for (i in gm_file_system_array) {
              gm_file_system_dict[gm_file_system_array[i]]="";
            }
          }
          {
            if ($3 in gm_file_system_dict) {
              printf "%s,", $1;
            }
          }' \
        | awk '{gsub(/,$/, ""); print}' 2>/dev/null
      ;;
    "solaris")
      df -n \
        | awk -v gm_file_system_list="${gm_file_system_list}" \
          'BEGIN {
            gsub(/[ ]+/, "", gm_file_system_list);
            gsub("\"", "", gm_file_system_list);
            split(gm_file_system_list, gm_file_system_array, ",");
            for (i in gm_file_system_array) {
              gm_file_system_dict[gm_file_system_array[i]]="";
            }
          }
          {
            if ($3 in gm_file_system_dict) {
              printf "%s,", $1;
            }
          }' \
        | awk '{gsub(/,$/, ""); print}' 2>/dev/null
      ;;
  esac

}