#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Command collector.
# Arguments:
#   string foreach: (optional)
#   string command: command
#   string output_directory: ful path to the output directory
#   string output_file: output file name (optional)
#   boolean compress_output_file: compress output file (optional) (default: false)
#   boolean redirect_stderr_to_stdout: redirect stderr to stdout (optional) (default: false)
# Returns:
#   none
_command_collector()
{
  __cc_foreach="${1:-}"
  __cc_command="${2:-}"
  __cc_output_directory="${3:-}"
  __cc_output_file="${4:-}"
  __cc_compress_output_file="${5:-false}"
  __cc_redirect_stderr_to_stdout="${6:-false}"

  if [ -z "${__cc_command}" ]; then
    _log_msg ERR "_command_collector: Empty command parameter"
    return 1
  fi

  if [ -z "${__cc_output_directory}" ]; then
    _log_msg ERR "_command_collector: Empty output_directory parameter"
    return 1
  fi

  if [ -n "${__cc_foreach}" ]; then

    _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__cc_foreach}"
    __cc_foreach_stdout=`_run_command "${__cc_foreach}"`

    # shellcheck disable=SC2162
    echo "${__cc_foreach_stdout}" \
      | sort -u \
      | while IFS= read __cc_line && [ -n "${__cc_line}" ]; do

          # replace %line% by __cc_line value
          __cc_new_command=`echo "${__cc_command}" | sed -e "s|%line%|${__cc_line}|g"`
          __cc_new_output_directory=`echo "${__cc_output_directory}" | sed -e "s|%line%|${__cc_line}|g"`
          
          __cc_new_output_directory=`_sanitize_output_directory "${__cc_new_output_directory}"`

          if [ ! -d  "${__cc_new_output_directory}" ]; then
            mkdir -p "${__cc_new_output_directory}" >/dev/null
          fi

          if [ -n "${__cc_output_file}" ]; then
            __cc_new_output_file=`echo "${__cc_output_file}" | sed -e "s|%line%|${__cc_line}|g"`
            __cc_new_output_file=`_sanitize_output_file "${__cc_new_output_file}" "${__cc_new_output_directory}" 240`
            
            if ${__cc_compress_output_file} && command_exists "gzip"; then
              __cc_new_output_file="${__cc_new_output_file}.gz"
              __cc_new_command="${__cc_new_command} | gzip - | cat -"
            fi

            _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__cc_new_command}"
            _run_command "${__cc_new_command}" "${__cc_redirect_stderr_to_stdout}" \
              >>"${__cc_new_output_directory}/${__cc_new_output_file}"

            # remove output file if it is empty
            if ${__cc_compress_output_file} && command_exists "gzip"; then
              __cc_compressed_file_size=`wc -c "${__cc_new_output_directory}/${__cc_new_output_file}" | awk '{print $1}'`
              if [ "${__cc_compressed_file_size}" -lt 21 ]; then
                rm -f "${__cc_new_output_directory}/${__cc_new_output_file}" >/dev/null
                _log_msg DBG "Empty compressed output file: '${__cc_new_output_file}'"
              fi
            elif [ ! -s "${__cc_new_output_directory}/${__cc_new_output_file}" ]; then
              rm -f "${__cc_new_output_directory}/${__cc_new_output_file}" >/dev/null
              _log_msg DBG "Empty output file: '${__cc_new_output_file}'"
            fi
          else
            _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__cc_new_command}"
            (
              cd "${__cc_new_output_directory}" \
              && _run_command "${__cc_new_command}" "${__cc_redirect_stderr_to_stdout}"
            )
          fi
        done

  else
    __cc_output_directory=`_sanitize_output_directory "${__cc_output_directory}"`

    if [ ! -d  "${__cc_output_directory}" ]; then
      mkdir -p "${__cc_output_directory}" >/dev/null
    fi

    if [ -n "${__cc_output_file}" ]; then
      __cc_output_file=`_sanitize_output_file "${__cc_output_file}" "${__cc_output_directory}" 240`
      if ${__cc_compress_output_file} && command_exists "gzip"; then
        __cc_output_file="${__cc_output_file}.gz"
        __cc_command="${__cc_command} | gzip - | cat -"
      fi
      _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__cc_command}"
      _run_command "${__cc_command}" "${__cc_redirect_stderr_to_stdout}" \
        >>"${__cc_output_directory}/${__cc_output_file}"

      # remove output file if it is empty
      if ${__cc_compress_output_file} && command_exists "gzip"; then
        __cc_compressed_file_size=`wc -c "${__cc_output_directory}/${__cc_output_file}" | awk '{print $1}'`
        if [ "${__cc_compressed_file_size}" -lt 21 ]; then
          rm -f "${__cc_output_directory}/${__cc_output_file}" >/dev/null
          _log_msg DBG "Empty compressed output file: '${__cc_output_file}'"
        fi
      elif [ ! -s "${__cc_output_directory}/${__cc_output_file}" ]; then
        rm -f "${__cc_output_directory}/${__cc_output_file}" >/dev/null
        _log_msg DBG "Empty output file: '${__cc_output_file}'"
      fi
    else
      _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__cc_command}"
      ( 
        cd "${__cc_output_directory}" \
        && _run_command "${__cc_command}" "${__cc_redirect_stderr_to_stdout}"
      )
    fi

  fi  
  
}