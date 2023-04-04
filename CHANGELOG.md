# Changelog

## DEVELOPMENT VERSION

### Artifacts

- live_response/containers/lxc.yaml: Added the collection of information about all active and inactive Linux containers and virtual machines (LXD), including their configuration, network, and storage information [linux].
- live_response/containers/pct.yaml: Added the collection of information about all active and inactive Linux containers (LXC) running on Proxmox VE [linux].
- live_response/containers/pct.yaml: Added the collection of the current configuration of Linux containers (LXC) running on Proxmox VE [linux].
- live_response/containers/pct.yaml: Added the collection of the list of assigned CPU sets for each Linux container (LXC) running on Proxmox VE [linux].
- live_response/process/deleted.yaml: Added the collection of files being hidden in a memfd socket [linux].
- live_response/storage/arcstat.yaml: Added the collection of ZFS ARC and L2ARC statistics [freebsd, linux, netbsd, openbsd, solaris].
- live_response/storage/findmnt.yaml: Added the collection of all mounted filesystems in the tree-like format [linux].
- live_response/storage/iostat.yaml: Updated the collection of device I/O statistics [aix, freebsd, linux, openbsd, solaris].
- live_response/storage/iscsiadm.yaml: Added the collection of information about iSCSI connected devices [linux].
- live_response/storage/ls_dev_disk.yaml: Added the collection of the mapping of logical volumes with physical disks [linux].
- live_response/storage/pvesm.yaml: Added the collection of status for all Proxmox VE datastores [linux].
- live_response/system/ha-manager.yaml: Added the collection of information about Proxmox VE HA manager status [linux].
- live_response/system/kernel_tainted_state.yaml: Added the collection of the kernel tainted state [linux].
- live_response/system/kernel_tainted_state.yaml: Added the collection of the list of what modules are marked at tainting the kernel [linux].
- live_response/system/pvecm.yaml: Added the collection of information about Proxmox VE local view of the cluster nodes [linux].
- live_response/system/pvecm.yaml: Added the collection of information about Proxmox VE local view of the cluster status [linux].
- live_response/system/pvesubscription.yaml: Added the collection of Proxmox VM subscription information [linux].
- live_response/system/pveum.yaml: Added the collection of Proxmox VE users and groups list [linux].
- live_response/system/pveversion.yaml: Added the collection of version information for Proxmox VE packages [linux].
- live_response/vms/qm.yaml: Added the collection of information about all active and inactive virtual machines running on Proxmox VE [linux].
- live_response/vms/qm.yaml: Added the collection of the current configuration of virtual machines running on Proxmox VE [linux].