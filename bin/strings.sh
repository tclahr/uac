#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

_command_exists()
{
  __co_command="${1:-}"

  if [ -z "${__co_command}" ]; then
    return 1
  fi

  if eval type type >/dev/null 2>/dev/null; then
    eval type "${__co_command}" >/dev/null 2>/dev/null
  elif command >/dev/null 2>/dev/null; then
    command -v "${__co_command}" >/dev/null 2>/dev/null
  else
    which "${__co_command}" >/dev/null 2>/dev/null
  fi
}

_strings() {
  if _command_exists "tr"; then
    tr '\0' '\n' | sed -n "s/\([[:print:]]\{${__STRING_LENGTH},\}\)/\
\1\
/gp" | sed -n "/[[:print:]]\{${__STRING_LENGTH},\}/p"
  elif _command_exists "perl"; then
    perl -pe 's/\0/\n/g' | sed -n "s/\([[:print:]]\{${__STRING_LENGTH},\}\)/\
\1\
/gp" | sed -n "/[[:print:]]\{${__STRING_LENGTH},\}/p"
  else
    sed 's/\x00/\n/g' | sed -n "s/\([[:print:]]\{${__STRING_LENGTH},\}\)/\
\1\
/gp" | sed -n "/[[:print:]]\{${__STRING_LENGTH},\}/p"
  fi
}

_usage() {
  printf "strings.sh version 1.0.0

Usage: strings.sh [OPTIONS] [FILE...]

Print the sequences of printable characters in files (stdin by default).
This is a shell implementation of the strings command.

OPTIONS:
  -f, --print-file-name   Print the name of the file before each string
  -n <number>             Set minimum string length (default: 4)
  -h, --help              Show this help message and exit

ARGUMENTS:
  FILE                    Input file path(s).
                          If no file is specified, reads from stdin.

EXAMPLES:
  strings.sh /bin/ls                # Extract strings from binary file
  strings.sh file1.bin file2.bin    # Process multiple files
  cat file.bin | strings.sh         # Read from stdin
  strings.sh -f file1.bin file2.bin # Print filename before each string
"
}

__PRINT_FILENAME=false
__STRING_LENGTH=4

# do not allow using undefined variables
set -u

while [ $# -gt 0 ]; do
  case "${1}" in
    "-h"|"--help")
      _usage
      exit 0
      ;;
    "-f"|"--print-file-name")
      __PRINT_FILENAME=true
      shift
      ;;
    "-n")
      if [ -z "${2:-}" ]; then
        printf "strings.sh: option '%s' requires an argument.\nTry 'strings.sh --help' for more information.\n" "${1}" >&2
        exit 1
      fi
      if [ "${2}" -eq "${2}" ] 2>/dev/null; then
        __STRING_LENGTH="${2}"
        shift
        shift
        continue
      fi
      printf "strings.sh: option '%s' requires an integer argument.\nTry 'strings.sh --help' for more information.\n" "${1}" >&2
      exit 1
      ;;
    -*)
      printf "strings.sh: invalid option '%s'\nTry 'strings.sh --help' for more information.\n" "${1}" >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

# if no files specified, read from stdin
if [ $# -eq 0 ]; then
  if [ "${__PRINT_FILENAME}" = true ]; then
    _strings | sed -e "s|^|\{standard input\}: |"
    exit 0
  fi
  _strings
else
  # process each file
  for __as_file in "$@"; do
    if [ ! -f "${__as_file}" ]; then
      echo "Error: File '${__as_file}' not found or not a regular file" >&2
      continue
    fi
    if [ ! -r "${__as_file}" ]; then
      echo "Error: Cannot read file '${__as_file}'" >&2
      continue
    fi
    if [ "${__PRINT_FILENAME}" = true ]; then
      _strings < "${__as_file}" | sed -e "s|^|${__as_file}: |"
      continue
    fi
    _strings < "${__as_file}"
  done
fi
