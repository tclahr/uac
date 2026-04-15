#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2003,SC2006

# Print system information.
# Arguments:
#   string operating_system: operating system
#   string mount_point: mount point
# Returns:
#   none
_system_info()
{
  __si_operating_system="${1:-}"
  
  __si_system_arch=`_get_system_arch "${__si_operating_system}"`
  __si_memory_size=`_get_memory_size "${__si_operating_system}"`
  __si_cpu_info=`_get_cpu_info "${__si_operating_system}"`
  __si_hostname=`_get_hostname "/"`
  __si_current_user=`_get_current_user`
  __si_timezone=`_get_timezone "/" "${__si_operating_system}"`

  printf "%s\n" "--------------------------------------------------------------------------------"
  printf "Operating System    : %s\n" "${__si_operating_system}"
  printf "System Architecture : %s\n" "${__si_system_arch}"
  printf "CPU                 : %s\n" "${__si_cpu_info}"
  printf "Memory Size         : %s MB\n" "${__si_memory_size}"
  printf "Hostname            : %s\n" "${__si_hostname}"
  printf "Time Zone           : %s\n" "${__si_timezone}"
  printf "Running as          : %s\n" "${__si_current_user}"
  printf "%s\n" "--------------------------------------------------------------------------------"
  printf "%-69s %10s\n" "Mount Point" "Used Size"
  printf "%s\n" "--------------------------------------------------------------------------------"
  _get_mount_point_used_size "${__si_operating_system}" \
    | awk -F'|' '
        {
          mount[NR] = $1
          kb[NR] = $2
        }

        END {
          # simple numeric sort (descending)
          for (i=1;i<=NR;i++) {
            for (j=i+1;j<=NR;j++) {
              if (kb[i] < kb[j]) {
                t=kb[i]; kb[i]=kb[j]; kb[j]=t
                m=mount[i]; mount[i]=mount[j]; mount[j]=m
              }
            }
          }

          for (i=1;i<=NR;i++) {
            size = kb[i]

            if (size >= 1024*1024*1024) {
              val = size/(1024*1024*1024); unit="TB"
            } else if (size >= 1024*1024) {
              val = size/(1024*1024); unit="GB"
            } else if (size >= 1024) {
              val = size/1024; unit="MB"
            } else {
              val = size; unit="KB"
            }
            printf "%-66s %10.2f %s\n", mount[i], val, unit
          }
        }
        '
  
}