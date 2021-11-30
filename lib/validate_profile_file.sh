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
# Validate profile file.
# Globals:
#   UAC_DIR
# Requires:
#   lrstrip
# Arguments:
#   $1: profile file
# Outputs:
#   None
# return Status:
#   return with status 0 on success.
#   return with status greater than 0 if errors occur.
###############################################################################
validate_profile_file()
{
  vp_profile_file="${1:-}"

  # return if profile file does not exist
  if [ ! -f "${vp_profile_file}" ]; then
    printf %b "uac: profile file: no such file or \
directory: '${vp_profile_file}'\n" >&2
    return 2
  fi

  vp_name=""
  vp_description=""
  vp_artifacts_prop=false
  vp_artifacts_file_prop=false
  vp_artifact_file=""
  vp_include_artifacts_file=false

  # add '__end__' line to the end of file
  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  printf %b "\n__end__" | cat "${vp_profile_file}" - \
    | sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' 2>/dev/null \
    | while IFS=":" read vp_key vp_value || [ -n "${vp_key}" ]; do

        vp_key=`lrstrip "${vp_key}"`

        case "${vp_key}" in
          "artifacts")
            if ${vp_artifacts_prop}; then
              printf %b "uac: profile file: invalid duplicated 'artifacts' \
mapping.\n" >&2
              return 4
            fi
            vp_artifacts_prop=true
            ;;
          "description")
            vp_description=`lrstrip "${vp_value}"`
            if [ -z "${vp_description}" ]; then
              printf %b "uac: profile file: 'description' \
must not be empty.\n" >&2
              return 5
            fi
            ;;
          "name")
            vp_name=`lrstrip "${vp_value}"`
            if [ -z "${vp_name}" ]; then
              printf %b "uac: profile file: 'name' \
must not be empty.\n" >&2
              return 11
            fi
            ;;
          "-"*)
            if [ ${vp_artifacts_prop} = false ]; then
              printf %b "uac: profile file: missing 'artifacts' \
mapping.\n" >&2
              return 6
            fi
            # extract file name from artifacts array
            vp_artifact_file=`echo "${vp_key}" | sed -e 's: *- *::g'`
            if [ -z "${vp_artifact_file}" ]; then
              printf %b "uac: profile file: invalid empty artifact \
entry.\n" >&2
              return 7
            fi

            if echo "${vp_artifact_file}" | grep -q -E "^!" 2>/dev/null; then
              vp_artifact_file=`echo "${vp_artifact_file}" | sed -e 's:^!::g'`
            else
              vp_include_artifacts_file=true
            fi
            vp_artifacts_file_prop=true

            find "${UAC_DIR}"/artifacts/${vp_artifact_file} -name "*.yaml" \
              -type f -print >/dev/null 2>/dev/null
            if [ "$?" -gt 0 ]; then
              printf %b "uac: profile file: no such \
file or directory: '"${UAC_DIR}"/artifacts/${vp_artifact_file}'\n" >&2
              return 8
            fi
            ;;
          "__end__")
            if [ ${vp_artifacts_file_prop} = false ]; then
              printf %b "uac: profile file: 'artifacts' must not be \
empty.\n" >&2
              return 9
            elif [ ${vp_include_artifacts_file} = false ]; then
              printf %b "uac: profile file: 'artifacts' must have at \
least one artifacts file.\n" >&2
              return 10
            fi
            if [ -z "${vp_name}" ]; then
              printf %b "uac: profile file: missing 'name' property.\n" >&2
              return 12
            fi
            ;;
          *)
            printf %b "uac: profile file: invalid property \
'${vp_key}'\n" >&2
            return 3
        esac

      done

}