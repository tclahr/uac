#!/bin/bash
# Hal Pomeranz (hrpomeranz@gmail.com) -- 2022-11-26
# Distributed under the Creative Commons Attribution-ShareAlike 4.0 license (CC BY-SA 4.0)

usage() {
    cat <<"EOM"
Dump process memory sections and extract ASCII strings from running processes

Usage: $0 [-p pid] [-b] [-s] [-u] -d dumpdir

    -p pid   Dump only a single PID, rather than all PIDs (default)
    -u       Put memory section data into "sections" subdir (for UAC output)
    -b       Encode memory sections by swapping bytes (protect from AV)
    -s       Output strings only, do not write out memory section data
EOM
    exit 1;
}

strings_only=0
swap_bytes=0
outputdir=''
user_pid=''
uac_path=''
while getopts "bd:p:su" opts; do
    case ${opts} in
        b) swap_bytes=1
           ;;
        d) outputdir=${OPTARG}
           ;;
	p) user_pid=${OPTARG}
	   ;;
	s) strings_only=1
           ;;
	u) uac_path='/sections'
           ;;
        *) usage
           ;;
    esac
done

[[ -z "$outputdir" ]] && usage			# Specify an output directory or error

if [[ -n "$user_pid" ]]; then			# One user specified PID or all PIDS?
    input_files="/proc/$user_pid/maps"
else
    input_files="/proc/[0-9]*/maps"
fi

# Dumping both strings and memory sections is accomplished using a FIFO to split the output
# into two streams. If we're only extracting strings, we don't need this.
#
if [[ $strings_only -eq 0 ]]; then
    fifo_path="$outputdir/.tempfifo"
    mkdir -p "$outputdir"
    mkfifo "$fifo_path"
fi

# Loop over all processes
for mapfile in $input_files; do
    pid=$(echo "$mapfile" | cut -f3 -d/)
    [[ $pid -eq $$ ]] && continue		# Don't dump our own process

    thisoutput="$outputdir/$pid"		# Where the output for this process goes
    mkdir -p "$thisoutput$uac_path"

    # Process the regions for this process
    cat "$mapfile" | sed 's/-/ /' | while read start end flags junk; do
	[[ "$flags" =~ ^r ]] || continue	# Skip unreadable sections

        start_page=$((16#$start / 4096))	# convert byte offset to page offset
	
        # If we are only dumping strings, then don't bother tee-ing data into a FIFO
        # If we are dumping memory regions with bytes swapped, then use "dd conv=swab" to read from FIFO
        # Otherwise just read the FIFO with "cat"
	#
	# Output from the main "dd" command is aggregated into "strings" at the end of the loop.
	# All data is gzip-ed to save space.
	#
	if [[ $strings_only -gt 0 ]]; then
	    dd if="/proc/$pid/mem" bs=4096 skip=$start_page count=$((16#$end / 4096 - $start_page))
	elif [[ $swap_bytes -gt 0 ]]; then
	    dd if="$fifo_path" conv=swab | gzip >"$thisoutput$uac_path/$start-$end.mem.swab.gz" &
	    dd if="/proc/$pid/mem" bs=4096 skip=$start_page count=$((16#$end / 4096 - $start_page)) | tee "$fifo_path"
	else
	    cat "$fifo_path" | gzip >"$thisoutput$uac_path/$start-$end.mem.gz" &
	    dd if="/proc/$pid/mem" bs=4096 skip=$start_page count=$((16#$end / 4096 - $start_page)) | tee "$fifo_path"
	fi
    done 2>/dev/null | strings -a | gzip >"$thisoutput/memory_strings.txt.gz"
done

# Get rid of the FIFO now that we're done
[[ $strings_only -eq 0 ]] && rm -f "$fifo_path"

