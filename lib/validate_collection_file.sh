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
# Validate collection file.
# Globals:
#   UAC_DIR
# Requires:
#   lrstrip
# Arguments:
#   $1: collection file
# Outputs:
#   None
# return Status:
#   return with status 0 on success.
#   return with status greater than 0 if errors occur.
###############################################################################
validate_collection_file()
{
  vc_collection_file="${1:-}"

  # return if collection file does not exist
  if [ ! -f "${vc_collection_file}" ]; then
    printf %b "uac: collection file: No such file or \
directory: '${vc_collection_file}'\n" >&2
    return 2
  fi

  vc_name=""
  vc_description=""
  vc_artifacts_prop=false
  vc_artifacts_file_prop=false
  vc_artifact_file=""
  vc_include_artifacts_file=false

  # add '__end__' line to the end of file
  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  printf %b "\n__end__" | cat "${vc_collection_file}" - \
    | sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' 2>/dev/null \
    | while IFS=":" read vc_key vc_value || [ -n "${vc_key}" ]; do

        vc_key=`lrstrip "${vc_key}"`

        case "${vc_key}" in
          "artifacts")
            if ${vc_artifacts_prop}; then
              printf %b "uac: collection file: invalid duplicated 'artifacts' \
mapping.\n" >&2
              return 4
            fi
            vc_artifacts_prop=true
            ;;
          "description")
            vc_description=`lrstrip "${vc_value}"`
            if [ -z "${vc_description}" ]; then
              printf %b "uac: collection file: 'description' \
must not be empty.\n" >&2
              return 5
            fi
            ;;
          "name")
            vc_name=`lrstrip "${vc_value}"`
            if [ -z "${vc_name}" ]; then
              printf %b "uac: collection file: 'name' \
must not be empty.\n" >&2
              return 11
            fi
            ;;
          "-"*)
            if [ ${vc_artifacts_prop} = false ]; then
              printf %b "uac: collection file: missing 'artifacts' \
mapping.\n" >&2
              return 6
            fi
            # extract file name from artifacts array
            vc_artifact_file=`echo "${vc_key}" | sed -e 's: *- *::g'`
            if [ -z "${vc_artifact_file}" ]; then
              printf %b "uac: collection file: invalid empty artifact \
entry.\n" >&2
              return 7
            fi

            if echo "${vc_artifact_file}" | grep -q -E "^!" 2>/dev/null; then
              vc_artifact_file=`echo "${vc_artifact_file}" | sed -e 's:^!::g'`
            else
              vc_include_artifacts_file=true
            fi
            vc_artifacts_file_prop=true

            find "${UAC_DIR}"/artifacts/${vc_artifact_file} -type f -print \
              >/dev/null \
              2>/dev/null
            if [ "$?" -gt 0 ]; then
              printf %b "uac: collection file: no such \
file or directory: '"${UAC_DIR}"/artifacts/${vc_artifact_file}'\n" >&2
              return 8
            fi
            ;;
          "__end__")
            if [ ${vc_artifacts_file_prop} = false ]; then
              printf %b "uac: collection file: 'artifacts' must not be \
empty.\n" >&2
              return 9
            elif [ ${vc_include_artifacts_file} = false ]; then
              printf %b "uac: collection file: 'artifacts' must have at \
least one artifacts file.\n" >&2
              return 10
            fi
            if [ -z "${vc_name}" ]; then
              printf %b "uac: collection file: missing 'name' property.\n" >&2
              return 12
            fi
            ;;
          *)
            printf %b "uac: collection file: invalid property \
'${vc_key}'\n" >&2
            return 3
        esac

      done

}