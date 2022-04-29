## Unix-like Artifacts Collector

[![ShellCheck](https://github.com/tclahr/uac/actions/workflows/shellcheck.yaml/badge.svg)](https://github.com/tclahr/uac/actions/workflows/shellcheck.yaml)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/5640/badge)](https://bestpractices.coreinfrastructure.org/projects/5640)
[![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/tclahr/uac?include_prereleases&style=flat)](https://github.com/tclahr/uac/releases)
[![GitHub](https://img.shields.io/github/license/tclahr/uac?style=flat)](LICENSE)

UAC is a Live Response collection script for Incident Response that makes use of native binaries and tools to automate the collection of AIX, Android, ESXi, FreeBSD, Linux, macOS, NetBSD, NetScaler, OpenBSD and Solaris systems artifacts. It was created to facilitate and speed up data collection, and depend less on remote support during incident response engagements.

[Documentation](#-documentation) •
[Main Features](#-main-features) •
[Supported Operating Systems](#-supported-operating-systems) •
[Using UAC](#-using-uac) •
[Contributing](#-contributing) •
[Support](#-community-support) •
[License](#-license)

[![Imgur](https://i.imgur.com/1aEnAyA.gif)](#)

***

## 📘 Documentation

Project documentation page: [https://tclahr.github.io/uac-docs](https://tclahr.github.io/uac-docs)

***

## 🌟 Main Features

- Runs everywhere with no dependencies (no installation required).
- Customizable and extensible collections and artifacts.
- Respects the order of volatility during artifacts collection.
- Collects information from processes running without a binary on disk.
- Extracts information from files and directories to create a bodyfile (including enhanced file attributes for ext4).
- Hashes running processes and executable files.
- Collects user and system configuration files and logs.
- Collects artifacts from applications.
- Acquires volatile memory from Linux systems using Microsoft's [avml](https://github.com/microsoft/avml) tool.

***

## 💾 Supported Operating Systems

UAC runs on any Unix-like system (regardless the processor architecture). All UAC needs is shell :)

[![AIX](https://img.shields.io/static/v1?label=&message=AIX&color=brightgreen&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![Android](https://img.shields.io/static/v1?label=&message=Android&color=green&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![ESXi](https://img.shields.io/static/v1?label=&message=ESXi&color=blue&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![FreeBSD](https://img.shields.io/static/v1?label=&message=FreeBSD&color=red&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![Linux](https://img.shields.io/static/v1?label=&message=Linux&color=lightgray&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![macOS](https://img.shields.io/static/v1?label=&message=macOS&color=blueviolet&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![NetBSD](https://img.shields.io/static/v1?label=&message=NetBSD&color=orange&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![NetScaler](https://img.shields.io/static/v1?label=&message=NetScaler&color=blue&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![OpenBSD](https://img.shields.io/static/v1?label=&message=OpenBSD&color=yellow&style=for-the-badge)](https://github.com/tclahr/uac/actions)
[![Solaris](https://img.shields.io/static/v1?label=&message=Solaris&color=lightblue&style=for-the-badge)](https://github.com/tclahr/uac/actions)

*Note that UAC even runs on systems like Network Attached Storage (NAS) devices, Network devices such as OpenWrt, and IoT devices.*

***

## 🚀 Using UAC

UAC does not need to be installed on the target system. You only need to download the latest version from the [releases page](https://github.com/tclahr/uac/releases), uncompress and run it. As simple as that!

A profile name and/or a list of artifacts, and the destination directory need to be provided in order to run a collection. The remaining parameters are optional.

Common usage scenarios may include the following:

**Collect all artifacts based on the ```full``` profile, and create the output file in ```/tmp```.**

```shell
./uac -p full /tmp
```

**Collect all ```live_response```, and the ```bodyfile/bodyfile.yaml``` artifact, and create the output file in the current directory.**

```shell
./uac -a live_response/\*,bodyfile/bodyfile.yaml .
```

**Collect all artifacts based on the ```full``` profile, but excludes the ```bodyfile/bodyfile.yaml``` artifact, and create the output file in ```/tmp```.**

```shell
./uac -p full -a \!bodyfile/bodyfile.yaml /tmp
```

**Note that when a profile and a list of artifacts are provided, the artifacts from the profile will always be collected first, even if the parameter ```-a``` was provided before ```-p``` in the command line. In the example below, the ```memory_dump/avml.yaml``` artifact will only be collected after all artifacts from ```full``` profile were collected.**

```shell
./uac -a memory_dump/avml.yaml -p full /tmp
```

**Collect all artifacts based on the ```full``` profile, but limiting the data collection based on the date range provided.**

```shell
./uac -p full /tmp --date-range-start 2021-05-01 --date-range-end 2021-08-31
```

**Collect all but live response artifacts from a Linux disk image mounted in ```/mnt/ewf```.**

```shell
./uac -p full -a \!live_response/\* /tmp --mount-point /mnt/ewf --operating-system linux
```

Please check the [project documentation page](https://tclahr.github.io/uac-docs) for more information about command line options, how to create your own artifacts, profiles, and more!

***

## 💙 Contributing

Have you created your own artifact files? Please share them with us!

You can contribute with new artifacts, profiles, bug fixes or even proposing new features. Please read our [Contributing Guide](CONTRIBUTING.md) before submitting a Pull Request to the project.

***

## 👨‍💻 Community Support

For general help using UAC, please refer to the [project documentation page](https://tclahr.github.io/uac-docs). For additional help, you can use one of the channels to ask a question:

- [Discord](https://discord.com/invite/digitalforensics) (For live discussion with the community and UAC team)
- [GitHub](https://github.com/tclahr/uac/issues) (Bug reports and contributions)
- [Twitter](https://twitter.com/tclahr) (Get the news fast)

***

## 📜 License

The UAC project uses the [Apache License Version 2.0](LICENSE) software license.