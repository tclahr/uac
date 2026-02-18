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

  printf "%s\n" "--------------------------------------------------------------------------------"
  printf "Operating System    : %s\n" "${__si_operating_system}"
  printf "System Architecture : %s\n" "${__si_system_arch}"
  printf "CPU                 : %s\n" "${__si_cpu_info}"
  printf "Memory Size         : %s MB\n" "${__si_memory_size}"
  printf "Hostname            : %s\n" "${__si_hostname}"
  printf "Running as          : %s\n" "${__si_current_user}"
  printf "%s\n" "--------------------------------------------------------------------------------"

}