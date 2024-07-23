<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="logo/uac-light.svg">
    <img src="logo/uac-dark.svg" alt="logo" width="120px">
  </picture>

  <h2 align="center">Unix-like Artifacts Collector</h2>

  <p align="center">
    <a href="https://github.com/tclahr/uac/actions/workflows/shellcheck.yaml" alt="Issues">
      <img src="https://github.com/tclahr/uac/actions/workflows/shellcheck.yaml/badge.svg" /></a>
    <a href="https://bestpractices.coreinfrastructure.org/projects/5640" alt="CII Best Practices">
      <img src="https://bestpractices.coreinfrastructure.org/projects/5640/badge" /></a>
    <a href="https://github.com/tclahr/uac/releases" alt="GitHub release (latest by date including pre-releases)">
      <img src="https://img.shields.io/github/v/release/tclahr/uac?include_prereleases&style=flat" /></a>
    <a href="https://github.com/tclahr/uac/LICENSE" alt="License">
      <img src="https://img.shields.io/github/license/tclahr/uac?style=flat" /></a>
  </p>

  <p align="center">
    <a href="#-documentation">Documentation</a>
    •
    <a href="#-main-features">Main Features</a>
    •
    <a href="#-supported-operating-systems">Supported Operating Systems</a>
    •
    <a href="">Using UAC</a>
    •
    <a href="#-contributing">Contributing</a>
    •
    <a href="#-community-support">Support</a>
    •
    <a href="#-license">License</a>
  </p>

</p>

## 🔎 About UAC

UAC is a Live Response collection script for Incident Response that makes use of native binaries and tools to automate the collection of AIX, ESXi, FreeBSD, Linux, macOS, NetBSD, NetScaler, OpenBSD and Solaris systems artifacts. It was created to facilitate and speed up data collection, and depend less on remote support during incident response engagements.

UAC reads YAML files on the fly and, based on their contents, collects relevant artifacts. This makes UAC very customizable and extensible.

[![uac_collection](https://tclahr.github.io/uac-docs/img/uac_3_collection.gif)](#)

## 📘 Documentation

Project documentation page: [https://tclahr.github.io/uac-docs](https://tclahr.github.io/uac-docs)

## 🌟 Main Features

- Run everywhere with no dependencies (no installation required).
- Customizable and extensible collections and artifacts.
- Respect the order of volatility during artifact collection.
- Collect information about current running processes (including processes without a binary on disk).
- Hash running processes and executable files.
- Extract files and directories status to create a bodyfile.
- Collect system and user-specific data, configuration files and logs.
- Acquire volatile memory from Linux systems using different methods and tools.

## 💾 Supported Operating Systems

UAC runs on any Unix-like system, regardless of the processor architecture. All UAC needs is shell :)

[![AIX](https://img.shields.io/static/v1?label=&message=AIX&color=brightgreen&style=for-the-badge)](#-supported-operating-systems)
[![ESXi](https://img.shields.io/static/v1?label=&message=ESXi&color=blue&style=for-the-badge)](#-supported-operating-systems)
[![FreeBSD](https://img.shields.io/static/v1?label=&message=FreeBSD&color=red&style=for-the-badge)](#-supported-operating-systems)
[![Linux](https://img.shields.io/static/v1?label=&message=Linux&color=lightgray&style=for-the-badge)](#-supported-operating-systems)
[![macOS](https://img.shields.io/static/v1?label=&message=macOS&color=blueviolet&style=for-the-badge)](#-supported-operating-systems)
[![NetBSD](https://img.shields.io/static/v1?label=&message=NetBSD&color=orange&style=for-the-badge)](#-supported-operating-systems)
[![NetScaler](https://img.shields.io/static/v1?label=&message=NetScaler&color=blue&style=for-the-badge)](#-supported-operating-systems)
[![OpenBSD](https://img.shields.io/static/v1?label=&message=OpenBSD&color=yellow&style=for-the-badge)](#-supported-operating-systems)
[![Solaris](https://img.shields.io/static/v1?label=&message=Solaris&color=lightblue&style=for-the-badge)](#-supported-operating-systems)

*Note that UAC even runs on systems like Network Attached Storage (NAS) devices, Network devices such as OpenWrt, and IoT devices.*

## 🚀 Usage

UAC does not need to be installed on the target system. Simply download the latest version from the [releases page](https://github.com/tclahr/uac/releases), uncompress it, and launch. It's that simple!

> **Full Disk Access** permission is a privacy feature introduced in macOS Mojave (10.14) that prevents some applications from accessing important data, such as Mail, Messages, and Safari files. So it is strongly recommended that you manually [grant permission for Terminal application](https://support.apple.com/guide/mac-help/allow-access-to-system-configuration-files-mchlccb25729/mac) before running UAC from the terminal, or [grant permission for remote users](https://support.apple.com/guide/mac-help/allow-a-remote-computer-to-access-your-mac-mchlp1066/mac) before running UAC via ssh.

To execute a collection, you must supply at least a profile and/or a list of artifacts, and specify the destination directory. Any additional parameters are optional.

Examples:

Collect all artifacts based on the ir_triage profile, and save the output file to /tmp.

```shell
./uac -p ir_triage /tmp
```

Collect all artifacts located in the artifacts/live_response directory, and save the output file to /tmp.

```shell
./uac -a ./artifacts/live_response/\* /tmp
```

Collect all artifacts based on the ir_triage profile, along with all artifacts located in the /my_custom_artifacts directory, and save the output file to /mnt/sda1.

```shell
./uac -p ir_triage -a /my_custom_artifacts/\* /mnt/sda1
```

Collect a memory dump and all artifacts based on the full profile.

```shell
./uac -a ./artifacts/memory_dump/avml.yaml -p full /tmp
```

Collect all artifacts based on the ir_triage profile excluding the bodyfile/bodyfile.yaml artifact.

```shell
./uac -p ir_triage -a \!artifacts/bodyfile/bodyfile.yaml /tmp
```

## 💙 Contributing

Contributions are what makes the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

Have you created any artifacts? Please share them with us!

You can contribute with new artifacts, profiles, bug fixes or even propose new features. Please read our [Contributing Guide](CONTRIBUTING.md) before submitting a Pull Request to the project.

## 👨‍💻 Community Support

For general help using UAC, please refer to the [project documentation page](https://tclahr.github.io/uac-docs). For additional help, you can use one of the channels to ask a question:

- [Discord](https://discord.com/invite/digitalforensics) (For live discussion with the community and UAC team)
- [GitHub](https://github.com/tclahr/uac/issues) (Bug reports and contributions)
- [Twitter](https://twitter.com/tclahr) (Get the news fast)

## 📜 License

The UAC project uses the [Apache License Version 2.0](LICENSE) software license.
