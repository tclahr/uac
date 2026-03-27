#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Replace a placeholder token in a shell fragment with a safely-escaped value.
# Tracks quoting context (double-quoted, single-quoted, unquoted) and escapes
# the value so the result is safe to pass to eval.
#
# Replacement rules:
#   - Inside double quotes: escape \, ", $, ` in value; insert as-is
#   - outside any quotes:   escape \, ", $, ` in value; wrap in double quotes
#   - Inside single quotes: insert value verbatim (no escaping needed)
#
# Arguments:
#   string input: shell fragment to process
#   string placeholder: full placeholder token including delimiters (e.g. %user%)
#   string value: replacement string (may contain shell-special chars)
# Returns:
#   string: shell fragment with placeholder replaced safely for eval
_replace_placeholder_shell_fragment()
{
  __rp_input="${1:-}"
  __rp_placeholder="${2:-}"
  __rp_value="${3:-}"

  if [ -z "${__rp_placeholder}" ]; then
    printf "%s" "${__rp_input}"
    return 0
  fi

  printf "%s" "${__rp_input}" \
    | awk \
      -v placeholder="${__rp_placeholder}" \
      -v value="${__rp_value}" \
      'BEGIN {
        escaped_value = escape_for_double_quotes(value)
        placeholder_len = length(placeholder)
        single_quote_char = sprintf("%c", 39)
      }

      function escape_for_double_quotes(str) {
        output=""
        for (i = 1; i <= length(str); i++) {
          char = substr(str, i, 1)
          if (char == "\\" || char == "\"" || char == "$" || char == "`") {
            output = output "\\" char
          } else {
            output = output char
          }
        }
        return output
      }

      {
        line = $0
        n = length(line)
        output = ""
        state = 0
        escaped = 0
        i = 1

        while (i <= n) {
          if (escaped == 0 && placeholder_len > 0 && substr(line, i, placeholder_len) == placeholder) {
            if (state == 1) {
              output = output escaped_value
            } else if (state == 2) {
              output = output value
            } else {
              output = output "\"" escaped_value "\""
            }
            i += placeholder_len
            escaped = 0
            continue
          }

          char = substr(line, i, 1)

          if (escaped) {
            output = output char
            escaped = 0
            i++
            continue
          }

          if (char == "\\") {
            if (state != 2) {
              escaped = 1
              output = output char
              i++
              continue
            }
            output = output char
            i++
            continue
          }

          if (char == "\"") {
            if (state == 0)      { state = 1 }
            else if (state == 1) { state = 0 }
            output = output char
            i++
            continue
          }

          if (char == single_quote_char) {
            if (state == 0)      { state = 2 }
            else if (state == 2) { state = 0 }
            output = output char
            i++
            continue
          }

          output = output char
          i++
        }

        printf "%s", output
      }'
}
