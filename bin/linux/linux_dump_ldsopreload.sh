#!/bin/bash
# Copyright 2024 Minoru Kobayashi <unknownbit@gmail.com> (@unkn0wnbit)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ref 1: https://www.youtube.com/watch?v=3UrEJzqqPYQ
# ref 2: https://righteousit.com/wp-content/uploads/2024/04/ld_preload-rootkits.pdf
# ref 3: https://www.youtube.com/watch?v=-K9hhqv21P8
# ref 4: https://righteousit.com/wp-content/uploads/2024/04/xfs_db-ftw.pdf

usage() {
    cat <<"EOM"
Dump /etc/ld.so.preload on XFS or EXT-based filesystem.

Usage: $0 [-d device] [-h] [-l sector_count] [-o outputfile] [-v]

    -d device         Specify the device which has /etc directory
    -h                Show this help message
    -l sector_count   Specify the sector count to dump (only for XFS, default: 1)
    -o outputfile     Specify the output file
    -v                Enable verbose mode
EOM
    exit 1;
}


print_msg() {
    if [ ${verbose_mode} -eq 1 ]; then
        echo $1
    fi
}


find_xfs_ldsopreload_inumber() {
    xfs_db -r $1 -c "daddr $2" -c "type dir3" -c "print" | awk '
    BEGIN {
        found_filename = 0;
        found_entry = 0;
    }

    {
        if ($0 ~ /du\[[0-9]+\].inumber = [0-9]+/) {
            match($0, /du\[[0-9]+\].inumber = ([0-9]+)/, arr);
            inumber = arr[1];
        }

        if ($0 ~ /du\[[0-9]+\].name = "ld.so.preload"/) {
            found_filename = 1;
        }

        if (found_filename && $0 ~ /du\[[0-9]+\].filetype = (1|7)/) {
            print inumber;
            found_entry = 1;
            exit;
        }
    }

    END {
        if (!found_entry) {
            print 0;
        }
    }
    '
}


dump_xfs_ldsopreload() {
    etc_dev_l=$1
    outputfile_l=$2
    sector_count_l=$3
    # Get inode number of /etc directory itself.
    etc_inumber=$(ls -id /etc | awk '{print $1}')

    # Get fsblock numbers of /etc directory.
    etc_fsblocks=$(xfs_db -r ${etc_dev_l} -c "inode ${etc_inumber}" -c "bmap" | awk '{print $5}')

    # Find inode number of /etc/ld.so.preload file.
    for etc_fsblock in ${etc_fsblocks}; do
        etc_daddr=$(xfs_db -r ${etc_dev_l} -c "convert fsblock ${etc_fsblock} daddr" | sed -n 's/.*(\([0-9]*\)).*/\1/p')
        ldsopreload_inumber=$(find_xfs_ldsopreload_inumber ${etc_dev_l} ${etc_daddr})
        if [ ${ldsopreload_inumber} -ne 0 ]; then
            break
        fi
    done

    if [ ${ldsopreload_inumber} -eq 0 ]; then
        print_msg "/etc/ld.so.preload not found."
        exit 3
    fi

    # Get fsblock numbers of /etc/ld.so.preload file.
    # In many cases, there is only one fsblock.
    ldsopreload_fsblocks=$(xfs_db -r ${etc_dev_l} -c "inode ${ldsopreload_inumber}" -c "bmap" | awk '{print $5}')

    # Convert fsblock numbers to daddr.
    ldsopreload_daddr=$(xfs_db -r ${etc_dev_l} -c "convert fsblock ${ldsopreload_fsblocks} daddr" | sed -n 's/.*(\([0-9]*\)).*/\1/p')

    # Dump /etc/ld.so.preload file.
    # I believe that /etc/ld.so.preload is not so large.
    sector_size=$(xfs_db -r /dev/mapper/rl-root -c "sb 0" -c "print" | grep -E "^sectsize" | awk '{print $3}')
    if [ -z "${outputfile_l}" ]; then
        dd if="${etc_dev_l}" bs="${sector_size}" skip="${ldsopreload_daddr}" count="${sector_count_l}" status=none
    else
        dd if="${etc_dev_l}" of="${outputfile_l}" bs="${sector_size}" skip="${ldsopreload_daddr}" count="${sector_count_l}" status=none
    fi
}


dump_ext_ldsopreload() {
    etc_dev_l=$1
    outputfile_l=$2
    # debugfs -R 'cat /etc/ld.so.preload' "${etc_dev_l}"
    if [ -z "${outputfile_l}" ]; then
        debugfs -R 'cat /etc/ld.so.preload' "${etc_dev_l}"
    else
        debugfs -R "dump /etc/ld.so.preload \"${outputfile_l}\"" "${etc_dev_l}"
    fi
}


sector_count=1
verbose_mode=0
while getopts "d:hl:o:v" opts; do
    case ${opts} in
        d) etc_dev=${OPTARG}
           ;;
        h) usage
           ;;
        l) sector_count=${OPTARG}
           ;;
        o) outputfile=${OPTARG}
           ;;
        v) verbose_mode=1
           ;;
        *) usage
           ;;
    esac
done

# Which device has /etc directory?
if [ -z "${etc_dev}" ]; then
    read etc_dev fs_type <<< $(df -T /etc | awk 'NR==2 {print $1, $2}')
else
    fs_type=$(df -T "${etc_dev}" | awk 'NR==2 {print $2}')
fi

# Check filesystem type and dump /etc/ld.so.preload
if [ "${fs_type}" = "xfs" ]; then
    dump_xfs_ldsopreload "${etc_dev}" "${outputfile}" "${sector_count}"
elif [[ "${fs_type}" =~ ^ext ]]; then
    dump_ext_ldsopreload "${etc_dev}" "${outputfile}"
else
    print_msg "/etc is not on XFS or EXT filesystem."
    exit 2
fi
