#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Parse command line arguments.
#   $@: all parameters passed to the script
# Returns:
#   boolean: true on success
#            false on fail
_parse_command_line_arguments()
{
  while [ ${#} -gt 0 ]; do
    case "${1}" in
      # optional arguments
      "-h"|"--help")
        _usage
        _exit_success
        ;;
      "-v"|"--verbose")
        __UAC_VERBOSE_MODE=true
        ;;
      "--debug")
        __UAC_DEBUG_MODE=true
        ;;
      "--trace")
        __UAC_TRACE_MODE=true
        ;;
      "-V"|"--version")
        printf "UAC (Unix-like Artifacts Collector) %s\n" "${__UAC_VERSION}"
        _exit_success
        ;;
      # profiling arguments
      "-p"|"--profile")
        if [ -n "${2:-}" ]; then
          # print available profiles
          if [ "${2}" = "list" ]; then
            _list_profiles "${__UAC_DIR}/profiles" || return 1
            _exit_success
          fi
          if [ -f "${2}" ]; then
            __pc_profile="${2}"
          else
            # get profile file based on the profile name
            __pc_profile=`_get_profile_by_name "${2}" "${__UAC_DIR}/profiles"`

            if [ -z "${__pc_profile}" ]; then
              _error_msg "Profile '${2}' does not exist.\nTry 'uac --profile list' to list all available profiles."
              return 1
            fi
          fi
          # check whether profile is valid
          _validate_profile "${__pc_profile}" "${__UAC_DIR}/artifacts" || return 1

          __pc_new_artifacts=`_parse_profile "${__pc_profile}" 2>/dev/null`
          
          __UAC_ARTIFACT_LIST="${__UAC_ARTIFACT_LIST}${__UAC_ARTIFACT_LIST:+,}${__pc_new_artifacts}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "-a"|"--artifacts")
        if [ -n "${2:-}" ]; then
          # print available artifacts
          if [ "${2}" = "list" ]; then
            _list_artifacts "${__UAC_DIR}/artifacts" "${3:-}" || return 1
            _exit_success
          fi
          __UAC_ARTIFACT_LIST="${__UAC_ARTIFACT_LIST}${__UAC_ARTIFACT_LIST:+,}${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      # output arguments
        "-o"|"--output-base-name")
          if [ -n "${2:-}" ]; then
            __UAC_OUTPUT_BASE_NAME="${2}"
            shift
          else
            _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
            return 1
          fi
          ;;
        "-f"|"--output-format")
          if [ -n "${2:-}" ]; then
            __UAC_OUTPUT_FORMAT="${2}"
            shift
          else
            _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
            return 1
          fi
          ;;
        "-P"|"--output-password")
          if [ -n "${2:-}" ]; then
            __UAC_OUTPUT_PASSWORD="${2}"
            shift
          else
            _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
            return 1
          fi
          ;;
      # collection arguments
      "-c"|"--config")
          if [ -n "${2:-}" ]; then
            __UAC_CUSTOM_CONFIG_FILE="${2}"
            shift
          else
            _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
            return 1
          fi
          ;;
      "-m"|"--mount-point")
        if [ -n "${2:-}" ]; then
          __UAC_MOUNT_POINT="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "-s"|"--operating-system")
        if [ -n "${2:-}" ]; then
          __UAC_OPERATING_SYSTEM="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "-H"|"--hash-collected")
        __UAC_HASH_COLLECTED=true
        ;;
      "-u"|"--run-as-non-root")
        __UAC_RUN_AS_NON_ROOT=true
        ;;
      "--enable-modifiers")
        __UAC_ENABLE_MODIFIERS=true
        ;;
      "--hostname")
        if [ -n "${2:-}" ]; then
          __UAC_HOSTNAME="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--temp-dir")
        if [ -n "${2:-}" ]; then
          __UAC_TEMP_DIR="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      # filter arguments
      "--start-date")
        if [ -n "${2:-}" ]; then
          __UAC_START_DATE="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--end-date")
        if [ -n "${2:-}" ]; then
          __UAC_END_DATE="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      # informational arguments
      "--case-number")
        if [ -n "${2:-}" ]; then
          __UAC_CASE_NUMBER="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--description")
        if [ -n "${2:-}" ]; then
          __UAC_EVIDENCE_DESCRIPTION="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--evidence-number")
        if [ -n "${2:-}" ]; then
          __UAC_EVIDENCE_NUMBER="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--examiner")
        if [ -n "${2:-}" ]; then
          __UAC_EXAMINER="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--notes")
        if [ -n "${2:-}" ]; then
          __UAC_EVIDENCE_NOTES="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      # remote transfer arguments
      "--sftp")
        if [ -n "${2:-}" ]; then
          __UAC_SFTP="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--sftp-port")
        if [ -n "${2:-}" ]; then
          __UAC_SFTP_PORT="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--sftp-identity-file")
        if [ -n "${2:-}" ]; then
          __UAC_SFTP_IDENTITY_FILE="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--sftp-ssh-option")
        if [ -n "${2:-}" ]; then
          __UAC_SFTP_SSH_OPTIONS="${__UAC_SFTP_SSH_OPTIONS} -o ${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--s3-provider")
        if [ -n "${2:-}" ]; then
          __UAC_S3_PROVIDER="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--s3-region")
        if [ -n "${2:-}" ]; then
          __UAC_S3_REGION="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--s3-bucket")
        if [ -n "${2:-}" ]; then
          __UAC_S3_BUCKET="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--s3-access-key")
        if [ -n "${2:-}" ]; then
          __UAC_S3_ACCESS_KEY="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--s3-secret-key")
        if [ -n "${2:-}" ]; then
          __UAC_S3_SECRET_KEY="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--s3-token")
        if [ -n "${2:-}" ]; then
          __UAC_S3_TOKEN="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--aws-s3-presigned-url")
        if [ -n "${2:-}" ]; then
          __UAC_AWS_S3_PRESIGNED_URL="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--aws-s3-presigned-url-log-file")
        if [ -n "${2:-}" ]; then
          __UAC_AWS_S3_PRESIGNED_URL_LOG_FILE="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--azure-storage-sas-url")
        if [ -n "${2:-}" ]; then
          __UAC_AZURE_STORAGE_SAS_URL="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--azure-storage-sas-url-log-file")
        if [ -n "${2:-}" ]; then
          __UAC_AZURE_STORAGE_SAS_URL_LOG_FILE="${2}"
          shift
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--delete-local-on-successful-transfer")
        __UAC_DELETE_LOCAL_ON_SUCCESSFUL_TRANSFER=true
        ;;
      # validation arguments
      "--validate-artifact")
        if [ -n "${2:-}" ]; then
          printf "Validating artifact '%s'...\n" "${2}"
          _validate_artifact "${2}" || return 1
          _exit_success "Artifact validation completed successfully."
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      "--validate-profile")
        if [ -n "${2:-}" ]; then
          printf "Validating profile '%s'...\n" "${2}"
          _validate_profile "${2}" || return 1
          _exit_success "Profile validation completed successfully."
        else
          _error_msg "Option '${1}' requires an argument.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
      # invalid arguments
      -*)
        _error_msg "Invalid option '${1}'.\nTry 'uac --help' for more information."
        return 1
        ;;
      # positional arguments
      *)
        if [ -z "${__UAC_DESTINATION_DIR}" ]; then
          __UAC_DESTINATION_DIR="${1}"
        else
          _error_msg "Invalid option '${1}'.\nTry 'uac --help' for more information."
          return 1
        fi
        ;;
    esac
    shift
  done
}
