#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Replace a placeholder in plain text that will not be evaluated by the shell.
# Arguments:
#   string input: plain text
#   string placeholder: full placeholder token including delimiters (e.g. %user%)
#   string value: replacement value
# Returns:
#   string: text with placeholder replaced literally
_replace_placeholder_plain_text()
{
  __rpp_input="${1:-}"
  __rpp_placeholder="${2:-}"
  __rpp_value="${3:-}"

  if [ -z "${__rpp_placeholder}" ]; then
    printf "%s" "${__rpp_input}"
    return 0
  fi

  printf "%s" "${__rpp_input}" \
    | awk \
      -v placeholder="${__rpp_placeholder}" \
      -v value="${__rpp_value}" '
      BEGIN {
        escaped_value = escape_for_gsub_replacement(value)
      }

      function escape_for_gsub_replacement(str) {
        output=""
        for (i = 1; i <= length(str); i++) {
          char = substr(str, i, 1)
          if (char == "&" || char == "\\" || char == "\"" || char == "$" || char == "`") {
            output = output "\\" char
          } else {
            output = output char
          }
        }
        return output
      }

      {
        gsub(placeholder, escaped_value, $0)
        printf "%s", $0
      }'

}
