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

set -euo pipefail

usage() {
    cat <<EOM
Dump /etc/ld.so.preload on XFS or EXT-based filesystem.

Usage: $0 [-f file] [-h] [-o outputfile] [-v]

    -f file         Specify a file to dump
    -h              Show this help message
    -o outputfile   Specify the output file
    -v              Enable verbose mode
EOM
    exit 1;
}


print_msg() {
    local msg=$1
    if [ ${verbose_mode} -eq 1 ]; then
        echo "${msg}" >&2
    fi
}


get_real_path() {
    local path=$1
    local processed_path=$2

    if [[ ! "$path" =~ ^(/|./|../) ]]; then
        if [[ "${processed_path}" == "/" ]]; then
            path="/${path}"
        else
            path="${processed_path}/${path}"
        fi
    fi
    realpath -s "${path}"
}


join_remain_path() {
    local index=$1
    local path_array=("${@:2}")
    local sub_path
    local old_IFS

    old_IFS="${IFS}"
    IFS='/'
    sub_path="${path_array[*]:${index}}"
    IFS="${old_IFS}"
    echo "${sub_path}"
}


get_device_fstype() {
    local path=$1
    local device
    local fs_type
    local mount_point

    read -r device fs_type mount_point <<< "$(df -T "$(dirname "${path}")" | awk 'NR==2 {print $1, $2, $NF}')"
    echo "${device}" "${fs_type}" "${mount_point}"
}


get_xfs_inumber_local() {
    local device=$1
    local root_inumber=$2
    local path=$3

    xfs_db -r "${device}" -c "inode ${root_inumber}" -c "print" | awk -v path="${path}" '
        BEGIN {
            found_filename = 0;
            found_entry = 0;
            filetype = 0;
        }

        {
            if ($0 ~ "u3.sfdir3.list\\[[0-9]+\\].name = \"" path "\"") {
                found_filename = 1;
            }

            if (found_filename && $0 ~ /u3.sfdir3.list\[[0-9]+\].inumber.i4 = [0-9]+/) {
                match($0, /u3.sfdir3.list\[[0-9]+\].inumber.i4 = ([0-9]+)/, arr);
                inumber = arr[1];
            }

            # filetype: 1 (regular file), 2 (directory), 7 (symlink)
            if (found_filename && $0 ~ /u3.sfdir3.list\[[0-9]+\].filetype = (1|2|7)/) {
                match($0, /u3.sfdir3.list\[[0-9]+\].filetype = ([0-9]+)/, arr);
                filetype = arr[1];
                found_entry = 1;
                exit;
            }
        }

        END {
            if (!found_entry) {
                inumber = 0;
            }
            print inumber, filetype;
        }
    '
}


get_xfs_inumber_extents() {
    local device=$1
    local fsblocks=$2
    local path=$3
    local fsblock
    local result

    for fsblock in ${fsblocks}; do
        result=$(xfs_db -r "${device}" -c "fsblock ${fsblock}" -c "type dir3" -c "print" | awk -v path="${path}" '
            BEGIN {
                found_name = 0;
                found_entry = 0;
            }

            {
                if ($0 ~ /(du|bu)\[[0-9]+\].inumber = [0-9]+/) {
                    match($0, /(du|bu)\[[0-9]+\].inumber = ([0-9]+)/, arr);
                    inumber = arr[2];
                }

                if ($0 ~ "(du|bu)\\[[0-9]+\\].name = \"" path "\"") {
                    found_name = 1;
                }

                if (found_name && $0 ~ /(du|bu)\[[0-9]+\].filetype = (1|2|7)/) {
                    match($0, /(du|bu)\[[0-9]+\].filetype = ([0-9]+)/, arr);
                    filetype = arr[2];
                    found_entry = 1;
                    exit;
                }
            }

            END {
                if (!found_entry) {
                    inumber = 0;
                }
                print inumber, filetype;
            }
        ')
        if [ "$(echo "${result}" | awk '{print $1}')" -ne 0 ]; then
            echo "${result}"
            return
        fi
    done
    echo 0 0
}


get_xfs_child_inumber() {
    local device=$1
    local parent_inumber=$2
    local path=$3
    local fsblocks
    local fsblock

    fsblocks=$(xfs_db -r "${device}" -c "inode ${parent_inumber}" -c "bmap" | awk '{print $5}')
    if [ -z "${fsblocks}" ]; then
        read -r inumber filetype <<< "$(get_xfs_inumber_local "${device}" "${parent_inumber}" "${path}")"
        echo "${inumber} ${filetype}"
        return
    else
        read -r inumber filetype <<< "$(get_xfs_inumber_extents "${device}" "${fsblocks}" "${path}")"
        echo "${inumber} ${filetype}"
        return
    fi
}


get_xfs_inumber_from_path() {
    local processed_path=""
    local full_path
    local device
    local fs_type
    local mount_point
    local root_inumber
    local parent_inumber
    local inumber=0
    local filetype=0
    local symlink_target
    local sub_path
    local idx
    local path_array
    local old_IFS

    full_path=$(get_real_path "$1" "${processed_path}")
    read -r device fs_type mount_point <<< "$(get_device_fstype "${full_path}")"
    # Remove mount_point from full_path if it starts with mount_point
    if [[ "${mount_point}" != "/" && "$full_path" == "$mount_point"* ]]; then
        full_path="${full_path/#${mount_point}/}"
    fi

    root_inumber=$(xfs_db -r "${device}" -c "sb 0" -c "print" | awk -F " = " '$1 == "rootino" {print $2}')
    parent_inumber=${root_inumber}

    old_IFS="${IFS}"
    IFS='/'
    read -r -a path_array <<< "${full_path}"
    IFS="${old_IFS}"

    for idx in "${!path_array[@]}"; do
        if [ "${idx}" -eq 0 ]; then
            processed_path="/"
            continue
        elif [ "${idx}" -ge 1 ]; then
            read -r inumber filetype <<< "$(get_xfs_child_inumber "${device}" "${parent_inumber}" "${path_array[$idx]}")"
            if [ "${inumber}" -eq 0 ]; then
                print_msg "${path_array[$idx]} not found."
                break
            elif [ "${filetype}" -eq 7 ]; then # If the file is a symlink, get the target file's inode number.
                symlink_target=$(xfs_db -r "${device}" -c "inode ${inumber}" -c "print" | sed -n 's/u3.symlink = "\(.*\)"/\1/p')
                print_msg "symlink target: ${symlink_target}"
                symlink_target=$(get_real_path "${symlink_target}" "${processed_path}")
                sub_path=$(join_remain_path $((idx+1)) "${path_array[@]}")
                if [ -n "${sub_path}" ]; then
                    symlink_target="${symlink_target}/${sub_path}"
                fi

                read -r inumber filetype <<< "$(get_xfs_inumber_from_path "${symlink_target}")"
                if [[ ! "${inumber}" =~ ^[0-9]+$ ]]; then
                    print_msg "${symlink_target} not found."
                    return 3
                fi

                echo "${inumber}" "${filetype}"
                return
            fi
            processed_path="${processed_path}/${path_array[$idx]}"
            parent_inumber=${inumber}
        fi
    done

    echo "${inumber}" "${filetype}"
}


dump_xfs_ldsopreload() {
    local file=$1
    local outputfile=$2
    local device=$3
    local block_count
    local inumber
    local filetype
    local fsblock_items
    local fsblock
    local agno
    local agblock

    # Get an inode number of the file.
    read -r inumber filetype <<< "$(get_xfs_inumber_from_path "${file}")"

    if [ "${inumber}" -eq 0 ]; then
        print_msg "${file} not found."
        exit 3
    fi

    # Get fsblock numbers of the file.
    fsblock_items=$(xfs_db -r "${device}" -c "inode ${inumber}" -c "bmap" | awk '{print $5, $8}')

    if [ -z "${fsblock_items}" ]; then
        print_msg "${file}: bmap not found."
        exit 4
    fi

    while read -r fsblock block_count; do
        # Convert fsblock to agno.
        agno=$(xfs_db -r "${device}" -c "convert fsblock ${fsblock} agno" | sed -n 's/.*(\([0-9]*\)).*/\1/p')

        if [ -z "${agno}" ]; then
            print_msg "${file}: agno not found."
            exit 5
        fi

        # Convert fsblock to agblock.
        agblock=$(xfs_db -r "${device}" -c "convert fsblock ${fsblock} agblock" | sed -n 's/.*(\([0-9]*\)).*/\1/p')

        if [ -z "${agblock}" ]; then
            print_msg "${file}: agblock not found."
            exit 6
        fi

        # Dump file data.
        sb0_output=$(xfs_db -r "${device}" -c "sb 0" -c "print")
        block_size=$(echo "${sb0_output}" | awk -F " = " '$1 == "blocksize" {print $2}')
        agblocks=$(echo "${sb0_output}" | awk -F " = " '$1 == "agblocks" {print $2}')
        skip_len=$((agno * agblocks + agblock))

        if [ -z "${outputfile}" ]; then
            dd if="${device}" bs="${block_size}" skip="${skip_len}" count="${block_count}" status=none
        else
            dd if="${device}" of="${outputfile}" bs="${block_size}" skip="${skip_len}" count="${block_count}" status=none
        fi
    done <<< "${fsblock_items}"
}


dump_ext_ldsopreload() {
    local full_path=$1
    local outputfile=$2
    local device=$3
    local fs_type
    local mount_point

    read -r device fs_type mount_point <<< "$(get_device_fstype "${full_path}")"

    # Remove mount_point from full_path if it starts with mount_point
    if [[ "${mount_point}" != "/" && "$full_path" == "$mount_point"* ]]; then
        full_path="${full_path/#${mount_point}/}"
    fi

    if [ -z "${outputfile}" ]; then
        debugfs -R "cat \"${full_path}\"" "${device}"
    else
        debugfs -R "dump \"${full_path}\" \"${outputfile}\"" "${device}"
    fi
}


file="/etc/ld.so.preload"
verbose_mode=0
while getopts "f:ho:v" opts; do
    case ${opts} in
        f) file=${OPTARG}
           ;;
        h) usage
           ;;
        o) outputfile=${OPTARG}
           ;;
        v) verbose_mode=1
           ;;
        *) usage
           ;;
    esac
done

# Which device has /etc/ld.so.preload?
file=$(realpath -s "${file}")
read -r device fs_type mount_point <<< "$(get_device_fstype "${file}")"

# Check filesystem type and dump /etc/ld.so.preload
if [ "${fs_type}" = "xfs" ]; then
    dump_xfs_ldsopreload "${file}" "${outputfile:-}" "${device}"
elif [[ "${fs_type}" =~ ^ext ]]; then
    dump_ext_ldsopreload "${file}" "${outputfile:-}" "${device}"
else
    print_msg "${file} is not on XFS or EXT filesystem."
    exit 2
fi
