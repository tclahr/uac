#!/usr/bin/env python3
"""Windows helper to deploy and run UAC on a remote Unix-like endpoint.

This script copies a local UAC directory to a remote host, mounts a remote share
on the target endpoint, executes UAC with its output written directly to that
mount, and then unmounts the share.

Requirements:
- Windows with Python 3.8+ installed.
- OpenSSH client available on Windows (ssh/scp in PATH).
- Remote endpoint reachable by SSH with the provided user.
- Remote endpoint able to mount the specified source and unmount it.
"""

from __future__ import annotations

import argparse
import os
import shlex
import subprocess
import sys
import uuid
from pathlib import Path


def run_command(command, capture_output=False, check=True, env=None):
    if capture_output:
        completed = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            text=True,
            shell=False,
            check=check,
        )
        return completed.stdout.strip(), completed.stderr.strip()

    return subprocess.run(command, env=env, shell=False, check=check)


def require_program(name):
    try:
        subprocess.run([name, "-V"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    except FileNotFoundError:
        raise RuntimeError(f"Required program '{name}' is not available in PATH.")


def build_ssh_command(args, remote_command):
    cmd = ["ssh"]
    if args.remote_port:
        cmd.extend(["-p", str(args.remote_port)])
    for option in args.ssh_options:
        cmd.extend(["-o", option])
    cmd.append(f"{args.remote_user}@{args.remote_host}")
    cmd.append(remote_command)
    return cmd


def build_scp_command(args, source, destination):
    cmd = ["scp", "-r"]
    if args.remote_port:
        cmd.extend(["-P", str(args.remote_port)])
    for option in args.ssh_options:
        cmd.extend(["-o", option])
    cmd.append(str(source))
    cmd.append(destination)
    return cmd


def quote_remote(path: str) -> str:
    return shlex.quote(path)


def remote_execute(args, remote_command, capture_output=False):
    command = build_ssh_command(args, remote_command)
    if args.verbose:
        print("SSH command:", " ".join(command))
    return run_command(command, capture_output=capture_output)


def remote_prepare_temp_dir(args, remote_temp_root):
    cmd = f"mkdir -p {quote_remote(remote_temp_root)}"
    remote_execute(args, cmd)


def remote_cleanup_temp_dir(args, remote_temp_root):
    cmd = f"rm -rf {quote_remote(remote_temp_root)}"
    remote_execute(args, cmd)


def remote_mount(args, mount_point, mount_source, mount_fstype, mount_options, mount_command, use_sudo):
    remote_execute(args, f"mkdir -p {quote_remote(mount_point)}")
    if mount_command:
        mount_cmd = mount_command
    else:
        if mount_fstype:
            fs_option = f"-t {shlex.quote(mount_fstype)}"
        else:
            fs_option = ""
        command_options = f"-o {shlex.quote(mount_options)}" if mount_options else ""
        mount_cmd = f"mount {fs_option} {command_options} {quote_remote(mount_source)} {quote_remote(mount_point)}"
    if use_sudo:
        mount_cmd = f"sudo sh -c {shlex.quote(mount_cmd)}"
    remote_execute(args, mount_cmd)


def remote_umount(args, mount_point, use_sudo):
    umount_cmd = f"umount {quote_remote(mount_point)}"
    if use_sudo:
        umount_cmd = f"sudo sh -c {shlex.quote(umount_cmd)}"
    remote_execute(args, umount_cmd)


def validate_local_uac_path(local_uac_path: Path) -> None:
    if not local_uac_path.exists() or not local_uac_path.is_dir():
        raise RuntimeError(f"Local UAC path does not exist or is not a directory: {local_uac_path}")
    if not (local_uac_path / "uac").exists():
        raise RuntimeError(f"Local UAC directory does not contain the 'uac' launcher: {local_uac_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Deploy UAC to a remote endpoint, mount output storage, execute UAC, and unmount.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument("--remote-host", required=True, help="Remote endpoint hostname or IP")
    parser.add_argument("--remote-user", required=True, help="Remote SSH user")
    parser.add_argument("--remote-port", type=int, help="SSH port")
    parser.add_argument("--ssh-option", action="append", dest="ssh_options", default=[], help="Additional SSH option to pass to ssh/scp")
    parser.add_argument("--local-uac-path", type=Path, default=Path.cwd(), help="Local path to the extracted UAC directory")
    parser.add_argument("--remote-temp-root", default="/tmp/uac_remote", help="Remote root directory to copy UAC into")
    parser.add_argument("--remote-temp-name", default=None, help="Remote temporary directory name, auto-generated if omitted")
    parser.add_argument("--mount-source", required=True, help="Remote mount source (share path, device, or network storage source)")
    parser.add_argument("--mount-point", required=True, help="Remote mount point where UAC output will be written")
    parser.add_argument("--mount-fstype", default="auto", help="Filesystem type for the remote mount")
    parser.add_argument("--mount-options", default="", help="Mount options for the remote mount")
    parser.add_argument("--mount-command", help="Custom remote mount command to use instead of the default mount invocation")
    parser.add_argument("--use-sudo", action="store_true", help="Use sudo for remote mount and unmount commands")
    parser.add_argument("--cleanup", action="store_true", help="Remove the remote temporary UAC directory after execution")
    parser.add_argument("--verbose", action="store_true", help="Print verbose progress information")
    parser.add_argument("--no-umount-on-error", action="store_true", help="Do not attempt to unmount if UAC execution fails")
    parser.add_argument("--uac-args", nargs=argparse.REMAINDER, help="Arguments to pass to the remote UAC invocation; specify after '--'", default=[])

    parsed = parser.parse_args()
    if parsed.uac_args and parsed.uac_args[0] == "--":
        parsed.uac_args = parsed.uac_args[1:]
    return parsed


def main():
    args = parse_args()
    if args.remote_temp_name:
        remote_temp_dir = f"{args.remote_temp_root.rstrip('/')}/{args.remote_temp_name}"
    else:
        remote_temp_dir = f"{args.remote_temp_root.rstrip('/')}/uac_{uuid.uuid4().hex[:8]}"

    args.local_uac_path = args.local_uac_path.expanduser().resolve()
    validate_local_uac_path(args.local_uac_path)

    require_program("ssh")
    require_program("scp")

    local_dir_name = args.local_uac_path.name
    remote_uac_dir = f"{remote_temp_dir}/{local_dir_name}"
    remote_parent = remote_temp_dir
    remote_target = f"{args.remote_user}@{args.remote_host}:{quote_remote(remote_parent)}"

    try:
        if args.verbose:
            print(f"Preparing remote temporary directory: {remote_temp_dir}")
        remote_prepare_temp_dir(args, remote_parent)

        if args.verbose:
            print(f"Copying local UAC directory '{args.local_uac_path}' to remote endpoint")
        scp_command = build_scp_command(args, args.local_uac_path, remote_target)
        if args.verbose:
            print("SCP command:", " ".join(scp_command))
        run_command(scp_command, check=True)

        if args.verbose:
            print(f"Mounting remote storage '{args.mount_source}' at '{args.mount_point}'")
        remote_mount(
            args,
            args.mount_point,
            args.mount_source,
            args.mount_fstype,
            args.mount_options,
            args.mount_command,
            args.use_sudo,
        )

        uac_command = [quote_remote(f"{remote_uac_dir}/uac")]
        if args.uac_args:
            uac_command.extend(shlex.quote(arg) for arg in args.uac_args)
        uac_command.append(quote_remote(args.mount_point))
        remote_run = " ".join(uac_command)
        if args.verbose:
            print("Running remote UAC command:", remote_run)
        stdout, stderr = remote_execute(args, remote_run, capture_output=True)
        print(stdout)
        if stderr:
            print(stderr, file=sys.stderr)

        if args.verbose:
            print(f"Unmounting remote mount point '{args.mount_point}'")
        remote_umount(args, args.mount_point, args.use_sudo)

    except subprocess.CalledProcessError as exc:
        if args.verbose:
            print(f"Remote execution failed: {exc}", file=sys.stderr)
        if not args.no_umount_on_error:
            try:
                remote_umount(args, args.mount_point, args.use_sudo)
            except Exception as umount_exc:
                print(f"Failed to unmount after error: {umount_exc}", file=sys.stderr)
        raise
    finally:
        if args.cleanup and args.remote_temp_root:
            if args.verbose:
                print(f"Cleaning up remote UAC directory '{remote_parent}'")
            try:
                remote_cleanup_temp_dir(args, remote_parent)
            except Exception as cleanup_exc:
                print(f"Failed to remove remote temp directory: {cleanup_exc}", file=sys.stderr)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
