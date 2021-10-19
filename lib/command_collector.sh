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
# Collector that runs commands.
# Globals:
#   GZIP_TOOL_AVAILABLE
#   TEMP_DATA_DIR
# Requires:
#   log_message
# Arguments:
#   $1: loop command (optional)
#   $2: command
#   $3: root output directory
#   $4: output directory (optional)
#   $5: output file
#   $6: compress output file (optional) (default: false)
# Outputs:
#   Write command output to stdout.
#   Write command errors to stderr.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
command_collector()
{
  cc_loop_command="${1:-}"
  cc_command="${2:-}"
  cc_root_output_directory="${3:-}"
  cc_output_directory="${4:-}"
  cc_output_file="${5:-}"
  cc_compress_output_file="${6:-false}"
  
  # return if command is empty
  if [ -z "${cc_command}" ]; then
    printf %b "command_collector: missing required argument: 'command'\n" >&2
    return 2
  fi

  # return if root output directory is empty
  if [ -z "${cc_root_output_directory}" ]; then
    printf %b "command_collector: missing required argument: \
'root_output_directory'\n" >&2
    return 3
  fi

  # return if output file is empty
  if [ -z "${cc_output_file}" ]; then
    printf %b "command_collector: missing required argument: 'output_file'\n" >&2
    return 4
  fi

  # loop command
  if [ -n "${cc_loop_command}" ]; then
    log_message COMMAND "${cc_loop_command}"
    eval "${cc_loop_command}" \
      >"${TEMP_DATA_DIR}/.loop_command.tmp" \
      2>>"${TEMP_DATA_DIR}/${cc_root_output_directory}/${cc_output_file}.stderr"
    
    if [ ! -s "${TEMP_DATA_DIR}/.loop_command.tmp" ]; then
      printf %b "command_collector: loop command returned zero lines: \
${cc_loop_command}\n" >&2
      return 5
    fi

    if "${cc_compress_output_file}" && ${GZIP_TOOL_AVAILABLE}; then
      log_message COMMAND "| sort -u | while read %line%; do ${cc_command} | gzip - | cat - ; done"
    else
      log_message COMMAND "| sort -u | while read %line%; do ${cc_command}; done"
    fi
    
    sort -u <"${TEMP_DATA_DIR}/.loop_command.tmp" \
      | while read cc_line || [ -n "${cc_line}" ]; do
          
          # replace %line% by cc_line value
          cc_new_command=`echo "${cc_command}" \
            | sed -e "s:%line%:${cc_line}:g"`
          
          # replace %line% by cc_line value
          cc_new_output_directory=`echo "${cc_output_directory}" \
            | sed -e "s:%line%:${cc_line}:g"`
          # sanitize output directory
          cc_new_output_directory=`sanitize_path \
            "${cc_root_output_directory}/${cc_new_output_directory}"`
          
          # replace %line% by cc_line value
          cc_new_output_file=`echo "${cc_output_file}" \
            | sed -e "s:%line%:${cc_line}:g"`
          # sanitize output file
          cc_new_output_file=`sanitize_filename \
            "${cc_new_output_file}"`

          # create output directory if it does not exist
          if [ ! -d  "${TEMP_DATA_DIR}/${cc_new_output_directory}" ]; then
            mkdir -p "${TEMP_DATA_DIR}/${cc_new_output_directory}" >/dev/null
          fi

          if "${cc_compress_output_file}" && ${GZIP_TOOL_AVAILABLE}; then
            # run command and append output to compressed file
            eval "${cc_new_command} | gzip - | cat -" \
              >>"${TEMP_DATA_DIR}/${cc_new_output_directory}/${cc_new_output_file}.gz" \
              2>>"${TEMP_DATA_DIR}/${cc_new_output_directory}/${cc_new_output_file}.stderr"
            # add output file to the list of files to be archived within the output file
            echo "${cc_new_output_directory}/${cc_new_output_file}.gz" \
              >>"${TEMP_DATA_DIR}/.output_file.tmp"
          else
            # run command and append output to existing file
            eval "${cc_new_command}" \
              >>"${TEMP_DATA_DIR}/${cc_new_output_directory}/${cc_new_output_file}" \
              2>>"${TEMP_DATA_DIR}/${cc_new_output_directory}/${cc_new_output_file}.stderr"
            # add output file to the list of files to be archived within the 
            # output file if it is not empty
            if [ -s "${TEMP_DATA_DIR}/${cc_new_output_directory}/${cc_new_output_file}" ]; then
              echo "${cc_new_output_directory}/${cc_new_output_file}" \
                >>"${TEMP_DATA_DIR}/.output_file.tmp"
            fi
          fi

          # add stderr file to the list of files to be archived within the 
          # output file if it is not empty
          if [ -s "${TEMP_DATA_DIR}/${cc_new_output_directory}/${cc_new_output_file}.stderr" ]; then
            echo "${cc_new_output_directory}/${cc_new_output_file}.stderr" \
              >>"${TEMP_DATA_DIR}/.output_file.tmp"
          fi

        done

    # add stderr file to the list of files to be archived within the 
    # output file if it is not empty
    if [ -s "${TEMP_DATA_DIR}/${cc_root_output_directory}/${cc_output_file}.stderr" ]; then
      echo "${cc_root_output_directory}/${cc_output_file}.stderr" \
        >>"${TEMP_DATA_DIR}/.output_file.tmp"
    fi
 
  else

    # sanitize output file name
    cc_output_file=`sanitize_filename "${cc_output_file}"`

    # sanitize output directory
    cc_output_directory=`sanitize_path \
      "${cc_root_output_directory}/${cc_output_directory}"`

    # create output directory if it does not exist
    if [ ! -d  "${TEMP_DATA_DIR}/${cc_output_directory}" ]; then
      mkdir -p "${TEMP_DATA_DIR}/${cc_output_directory}" >/dev/null
    fi

    if "${cc_compress_output_file}" && ${GZIP_TOOL_AVAILABLE}; then
      # run command and append output to compressed file
      log_message COMMAND "${cc_command} | gzip - | cat -"
      eval "${cc_command} | gzip - | cat -" \
        >>"${TEMP_DATA_DIR}/${cc_output_directory}/${cc_output_file}.gz" \
        2>>"${TEMP_DATA_DIR}/${cc_output_directory}/${cc_output_file}.stderr"
      # add output file to the list of files to be archived within the output file
      echo "${cc_output_directory}/${cc_output_file}.gz" \
        >>"${TEMP_DATA_DIR}/.output_file.tmp"
    else
      # run command and append output to existing file
      log_message COMMAND "${cc_command}"
      eval "${cc_command}" \
        >>"${TEMP_DATA_DIR}/${cc_output_directory}/${cc_output_file}" \
        2>>"${TEMP_DATA_DIR}/${cc_output_directory}/${cc_output_file}.stderr"
      # add output file to the list of files to be archived within the 
      # output file if it is not empty
      if [ -s "${TEMP_DATA_DIR}/${cc_output_directory}/${cc_output_file}" ]; then
        echo "${cc_output_directory}/${cc_output_file}" \
          >>"${TEMP_DATA_DIR}/.output_file.tmp"
      fi
    fi

    # add stderr file to the list of files to be archived within the 
    # output file if it is not empty
    if [ -s "${TEMP_DATA_DIR}/${cc_output_directory}/${cc_output_file}.stderr" ]; then
      echo "${cc_output_directory}/${cc_output_file}.stderr" \
        >>"${TEMP_DATA_DIR}/.output_file.tmp"
    fi

  fi

}