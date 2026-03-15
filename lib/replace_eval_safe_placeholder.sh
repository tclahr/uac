#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Replace a placeholder in a shell fragment that will later be evaluated.
# Placeholders found inside double quotes receive a double-quote-safe value,
# while placeholders outside double quotes become single-quoted shell literals.
# Arguments:
#   string input: shell fragment
#   string placeholder: placeholder name without surrounding %
#   string value: replacement value
# Returns:
#   string: shell fragment with placeholder replaced safely for eval
_replace_eval_safe_placeholder()
{
  __resp_input="${1:-}"
  __resp_placeholder="${2:-}"
  __resp_value="${3:-}"

  if [ -z "${__resp_placeholder}" ]; then
    printf "%s" "${__resp_input}"
    return 0
  fi

  printf "%s\n" "${__resp_input}" \
    | awk -v token="%${__resp_placeholder}%" -v raw="${__resp_value}" '
        function escape_for_double_quotes(str,    out, i, ch) {
          out=""
          for (i = 1; i <= length(str); i++) {
            ch = substr(str, i, 1)
            if (ch == "\\" || ch == "\"" || ch == "$" || ch == "`") {
              out = out "\\" ch
            } else {
              out = out ch
            }
          }
          return out
        }
        function quote_for_shell(str,    out, i, ch, sq_char) {
          sq_char = sprintf("%c", 39)
          out = sq_char
          for (i = 1; i <= length(str); i++) {
            ch = substr(str, i, 1)
            if (ch == sq_char) {
              out = out sq_char "\"" sq_char "\"" sq_char
            } else {
              out = out ch
            }
          }
          out = out sq_char
          return out
        }
        {
          double_quoted_value = escape_for_double_quotes(raw)
          shell_quoted_value = quote_for_shell(raw)
          line = $0
          out = ""
          in_double_quotes = 0
          escaped = 0
          i = 1

          while (i <= length(line)) {
            ch = substr(line, i, 1)

            if (escaped) {
              out = out ch
              escaped = 0
              i++
              continue
            }

            if (ch == "\\") {
              out = out ch
              escaped = 1
              i++
              continue
            }

            if (substr(line, i, length(token)) == token) {
              if (in_double_quotes) {
                out = out double_quoted_value
              } else {
                out = out shell_quoted_value
              }
              i += length(token)
              continue
            }

            if (ch == "\"") {
              in_double_quotes = !in_double_quotes
            }

            out = out ch
            i++
          }

          print out
        }
      ' 2>/dev/null
}

# Replace a placeholder in plain text that will not be evaluated by the shell.
# Arguments:
#   string input: plain text
#   string placeholder: placeholder name without surrounding %
#   string value: replacement value
# Returns:
#   string: text with placeholder replaced literally
_replace_plain_placeholder()
{
  __rpp_input="${1:-}"
  __rpp_placeholder="${2:-}"
  __rpp_value="${3:-}"
  __rpp_escaped_value=""

  if [ -z "${__rpp_placeholder}" ]; then
    printf "%s" "${__rpp_input}"
    return 0
  fi

  __rpp_escaped_value=$(printf "%s" "${__rpp_value}" \
    | sed -e 's|[\\&|]|\\&|g' 2>/dev/null)

  printf "%s" "${__rpp_input}" \
    | sed -e "s|%${__rpp_placeholder}%|${__rpp_escaped_value}|g" 2>/dev/null
}
