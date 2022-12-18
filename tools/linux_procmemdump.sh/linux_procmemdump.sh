#!/bin/bash
# Hal Pomeranz (hrpomeranz@gmail.com) -- 2022-11-26
# Distributed under the Creative Commons Attribution-ShareAlike 4.0 license (CC BY-SA 4.0)

usage() {
    cat <<"EOM"
Dump process memory sections and extract ASCII strings from running processes

Usage: $0 -p pid [-b] [-s] -d dumpdir

    -p pid   Process ID (PID)
    -b       Encode memory sections by swapping bytes (protect from AV)
    -s       Output strings only, do not write out memory section data
EOM
    exit 1;
}

strings_only=0
swap_bytes=0
outputdir=""
user_pid=""
while getopts "bd:p:su" opts; do
    case ${opts} in
        b) swap_bytes=1
           ;;
        d) outputdir="${OPTARG}"
           ;;
        p) user_pid="${OPTARG}"
           ;;
        s) strings_only=1
           ;;
        *) usage
           ;;
    esac
done

[[ -z "${user_pid}" ]] && usage    # Specify a PID or error

[[ -z "${outputdir}" ]] && usage    # Specify an output directory or error

# Dumping both strings and memory sections is accomplished using a FIFO to split the output
# into two streams. If we're only extracting strings, we don't need this.
#
if [[ ${strings_only} -eq 0 ]]; then
    fifo_path="${outputdir}/.tempfifo"
    mkdir -p "${outputdir}"
    mkfifo "${fifo_path}"
fi

mkdir -p "${outputdir}"

# Process the regions for this process
# shellcheck disable=SC2002,SC2162,SC2034
cat "/proc/${user_pid}/maps" | sed 's/-/ /' | while read start end flags junk; do
    [[ "${flags}" =~ ^r ]] || continue    # Skip unreadable sections

    start_page=$((16#${start} / 4096))    # convert byte offset to page offset

    # If we are only dumping strings, then don't bother tee-ing data into a FIFO
    # If we are dumping memory regions with bytes swapped, then use "dd conv=swab" to read from FIFO
    # Otherwise just read the FIFO with "cat"
    #
    # Output from the main "dd" command is aggregated into "strings" at the end of the loop.
    # All data is gzip-ed to save space.
    #
    if [[ ${strings_only} -gt 0 ]]; then
        dd if="/proc/${user_pid}/mem" bs=4096 skip=${start_page} count=$((16#${end} / 4096 - start_page))
    elif [[ ${swap_bytes} -gt 0 ]]; then
        dd if="${fifo_path}" conv=swab | gzip >"${outputdir}/${start}-${end}.mem.swab.gz" &
        dd if="/proc/${user_pid}/mem" bs=4096 skip=${start_page} count=$((16#${end} / 4096 - start_page)) | tee "${fifo_path}"
    else
        cat "${fifo_path}" | gzip >"${outputdir}/${start}-${end}.mem.gz" &
        dd if="/proc/${user_pid}/mem" bs=4096 skip=${start_page} count=$((16#${end} / 4096 - start_page)) | tee "${fifo_path}"
    fi
done | strings -a | gzip >"${outputdir}/strings.txt.gz"

# Get rid of the FIFO now that we're done
[[ -e "${fifo_path}" ]] && rm -f "${fifo_path}"
