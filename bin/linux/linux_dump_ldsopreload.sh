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

# reference: https://www.youtube.com/watch?v=-K9hhqv21P8

usage() {
    cat <<"EOM"
Dump /etc/ld.so.preload (first sector only) with xfs_db

Usage: $0 [-d dumpdir]

    -d device         Specify the device which has /etc directory
    -h                Show this help message
    -l sector_count   Specify the sector count to dump (default: 1)
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


find_ldsopreload_inumber() {
    xfs_db -r $1 -c "daddr $2" -c "type dir3" -c "print" | awk '
    {
        if ($0 ~ /du\[([0-9]+)\].inumber = ([0-9]+)/) {
            match($0, /du\[([0-9]+)\].inumber = ([0-9]+)/, arr);
            inumber[arr[1]] = arr[2];  # arr[1] = NUM, arr[2] = inumber
        }

        if ($0 ~ /du\[([0-9]+)\].name = "ld.so.preload"/) {
            match($0, /du\[([0-9]+)\].name = "ld.so.preload"/, arr);
            num = arr[1];  # arr[1] = NUM
            if (num in inumber) {
                # print "name: " $0 ", inumber: " inumber[num];
                print inumber[num];
                found = 1;
            }
        }
    }

    END {
        if (!found) {
            print 0;
        }
    }
    '
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
    etc_dev=`df -T /etc | awk '$2 == "xfs" {print $1}'`
    if [ -z "${etc_dev}" ]; then
        print_msg "/etc is not on XFS filesystem."
        exit 2
    fi
else
    if [ `df -T "${etc_dev}" | awk 'NR==2 {print $2}'` != "xfs" ]; then
        print_msg "${etc_dev} is not XFS filesystem."
        exit 2
    fi
fi

# Get inode number of /etc directory itself.
etc_inumber=`ls -id /etc | awk '{print $1}'`

# Get fsblock numbers of /etc directory.
etc_fsblocks=`xfs_db -r ${etc_dev} -c "inode ${etc_inumber}" -c "bmap" | awk '{print $5}'`

# Find inode number of /etc/ld.so.preload file.
for etc_fsblock in ${etc_fsblocks}; do
    etc_daddr=`xfs_db -r ${etc_dev} -c "convert fsblock ${etc_fsblock} daddr" | sed -n 's/.*(\([0-9]*\)).*/\1/p'`
    ldsopreload_inumber=`find_ldsopreload_inumber ${etc_dev} ${etc_daddr}`
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
ldsopreload_fsblocks=`xfs_db -r ${etc_dev} -c "inode ${ldsopreload_inumber}" -c "bmap" | awk '{print $5}'`

# Convert fsblock numbers to daddr.
ldsopreload_daddr=`xfs_db -r ${etc_dev} -c "convert fsblock ${ldsopreload_fsblocks} daddr" | sed -n 's/.*(\([0-9]*\)).*/\1/p'`

# Dump /etc/ld.so.preload file.
# I believe that /etc/ld.so.preload is not so large.
sector_size=`xfs_db -r /dev/mapper/rl-root -c "sb 0" -c "print" | grep -E "^sectsize" | awk '{print $3}'`
if [ -z "${outputfile}" ]; then
    dd if="${etc_dev}" bs="${sector_size}" skip="${ldsopreload_daddr}" count="${sector_count}" status=none
else
    dd if="${etc_dev}" of="${outputfile}" bs="${sector_size}" skip="${ldsopreload_daddr}" count="${sector_count}" status=none
fi
