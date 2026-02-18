#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2003,SC2006

# Get CPU information.
# Arguments:
#   string operating_system: operating system name
# Returns:
#   string: CPU information
_get_cpu_info()
{
  __gci_operating_system="${1:-}"
  __gci_return_string=""

  case "${__gci_operating_system}" in
    "aix")
      __gci_cpu_type=`lsattr -El proc0 -a type | awk '{print $2}' | sed -e 's|^ *||' -e 's| *$||'`
      __gci_cores=`lsdev -Cc processor | wc -l | awk '{print $1}'`
      __gci_clock_speed=`lsattr -El proc0 -a frequency | awk '{print int($2/1000000)}'`
      __gci_return_string="${__gci_cpu_type:-Unknown} @ ${__gci_clock_speed:-0} Mhz (Cores: ${__gci_cores:-0})"
      ;;
    "esxi")
      __gci_cpu_type=`vim-cmd hostsvc/hostsummary | awk -F= '/cpuModel/ {print $2}' | sed -e 's|"||g' -e 's|, *$||' -e 's|^ *||' -e 's| *$||'`
      __gci_cores=`vim-cmd hostsvc/hostsummary | awk -F= '/numCpuCores/ {print $2}' | sed -e 's|"||g' -e 's|, *$||' -e 's|^ *||' -e 's| *$||'`
      __gci_clock_speed=`vim-cmd hostsvc/hostsummary | awk -F= '/cpuMhz/ {print $2}' | sed -e 's|"||g' -e 's|, *$||' -e 's|^ *||' -e 's| *$||'`
      __gci_return_string="${__gci_cpu_type:-Unknown} @ ${__gci_clock_speed:-0} Mhz (Cores: ${__gci_cores:-0})"
      ;;
    "freebsd")
      __gci_cpu_type=`sysctl -n hw.model | sed -e 's|^ *||' -e 's| *$||'`
      __gci_cores=`sysctl -n hw.ncpu`
      __gci_clock_speed=`sysctl -n hw.clockrate || sysctl -n hw.cpuspeed`
      __gci_return_string="${__gci_cpu_type:-Unknown} @ ${__gci_clock_speed:-0} Mhz (Cores: ${__gci_cores:-0})"
      ;;
    "linux"|"netbsd")
      __gci_cpu_type=`awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed -e 's|^ *||' -e 's| *$||'`
      if [ -z "${__gci_cpu_type}" ]; then # old kernels
        __gci_cpu_type=`awk -F: '/cpu model/ {print $2; exit}' /proc/cpuinfo | sed -e 's|^ *||' -e 's| *$||'`
      fi
      __gci_cores=`awk '/^processor/ {c++} END {print c}' /proc/cpuinfo`
      __gci_clock_speed=`awk -F: '/cpu MHz/ {print int($2); exit}' /proc/cpuinfo`
      if [ -z "${__gci_clock_speed}" ]; then #old kernels
        __gci_clock_speed=`awk -F: '/CPU frequency/ {print int($2/1000000); exit}' /proc/cpuinfo`
      fi
      __gci_return_string="${__gci_cpu_type:-Unknown} @ ${__gci_clock_speed:-0} Mhz (Cores: ${__gci_cores:-0})"
      ;;
    "macos")
      __gci_cpu_type=`sysctl -n machdep.cpu.brand_string | sed -e 's|^ *||' -e 's| *$||'`
      __gci_cores=`sysctl -n hw.physicalcpu`
      __gci_clock_speed=`sysctl -n hw.cpufrequency | awk '{print int($1/1000000)}'`
      __gci_return_string="${__gci_cpu_type:-Unknown} @ ${__gci_clock_speed:-0} Mhz (Cores: ${__gci_cores:-0})"
      ;;
    "netscaler")
      __gci_cpu_type=`sysctl -n hw.model | sed -e 's|^ *||' -e 's| *$||'`
      __gci_cores=`sysctl -n hw.ncpu`
      __gci_clock_speed=`sysctl -n hw.clockrate`
      __gci_return_string="${__gci_cpu_type:-Unknown} @ ${__gci_clock_speed:-0} Mhz (Cores: ${__gci_cores:-0})"
      ;;
    "openbsd")
      __gci_cpu_type=`sysctl -n hw.model | sed -e 's|^ *||' -e 's| *$||'`
      __gci_cores=`sysctl -n hw.ncpuonline`
      __gci_clock_speed=`sysctl -n hw.cpuspeed`
      __gci_return_string="${__gci_cpu_type:-Unknown} @ ${__gci_clock_speed:-0} Mhz (Cores: ${__gci_cores:-0})"
      ;;
    "solaris")
      __gci_cpu_type=`psrinfo -pv | awk 'NR==2{print; exit}' | sed -e 's|^ *||' -e 's| *$||'`
      __gci_return_string="${__gci_cpu_type:-Unknown}"
      ;;
  esac

  printf "%s" "${__gci_return_string}"  

}
