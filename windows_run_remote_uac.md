# Windows Remote UAC Runner

This helper script deploys UAC to a remote Unix-like endpoint, mounts remote storage on the target, runs UAC with the mount as the output directory, and then unmounts the storage.

## File

- `windows_run_remote_uac.py` — Windows Python helper script.

## Requirements

- Windows with Python 3.8+ installed.
- `ssh` and `scp` available on Windows (OpenSSH client in PATH).
- Remote endpoint reachable by SSH.
- Remote endpoint capable of mounting the specified storage source and writing output to the mount point.

## Usage

```powershell
python windows_run_remote_uac.py \
  --remote-host 10.0.0.1 \
  --remote-user root \
  --mount-source //fileserver/share_5g7b2 \
  --mount-point /mnt/4g7k9 \
  --mount-fstype cifs \
  --mount-options "username=root,password=Aa123456,uid=0" \
  --local-uac-path C:\workspaces\uac \
  --cleanup \
  --verbose -- --profile ir_triage
```

### Key options

- `--remote-host` — Remote SSH host or IP address.
- `--remote-user` — SSH username on the remote endpoint. The script will prompt for the SSH password if password authentication is enabled.
- `--mount-source` — Remote mount source, such as a network share or block device. Use a random 5-character alphanumeric name for the share/mount identifier if desired.
- `--mount-point` — Remote directory where the mount is created. Use a random 5-character alphanumeric suffix for a temporary mount point.
- `--mount-point` — Remote directory where the mount is created.
- `--mount-fstype` — Filesystem type for `mount`.
- `--mount-options` — Mount options to pass to the remote `mount` command.
- `--local-uac-path` — Local path to the extracted UAC directory.
- `--cleanup` — Remove the temporary remote UAC copy after execution.
- `--verbose` — Print progress and command information.
- `--` — All following arguments are passed directly to the remote `uac` invocation.

## Behavior

1. Copies the local UAC directory to a temporary remote directory.
2. Mounts the specified remote storage on the remote endpoint.
3. Executes UAC with the remote mount point as the destination.
4. Unmounts the storage after UAC finishes.
5. Optionally cleans up the remote temporary copy.

## Notes

- The helper assumes the remote host has the standard `mount` and `umount` commands available.
- If you need a custom mount command, use `--mount-command`.
- If the remote command requires elevated permissions, add `--use-sudo`.
