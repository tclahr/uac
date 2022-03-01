<pre align="center" style="background-color: transparent; font-weight: bold;">
 __   __ _______ _______ 
|: | |  |:  _   |:  ____|
|  |_|  |  | |  |  |____ 
|_______|__| |__|_______|

Unix-like Artifacts Collector
</pre>
<p align="center">
  <a href="https://github.com/tclahr/uac/issues"><img src="https://img.shields.io/github/issues/tclahr/uac" alt="GitHub Issues" /></a>
  <a href="https://github.com/tclahr/uac/issues?q=is%3Aissue+is%3Aclosed"><img src="https://img.shields.io/github/issues-closed-raw/tclahr/uac" alt="GitHub Closed Issues" /></a>
  <a href="https://github.com/tclahr/uac/releases"><img src="https://img.shields.io/github/v/release/tclahr/uac" alt="GitHub Release" /></a>
  <a href="https://github.com/tclahr/uac/blob/main/LICENSE"><img src="https://img.shields.io/github/license/tclahr/uac" alt="License" /></a>
</p>

## Description

UAC is a Live Response collection tool for Incident Response that makes use of native binaries to automate the collection of Unix-like systems artifacts. It was created to facilitate and speed up data collection, and depend less on remote support during incident response engagements.

UAC reads artifacts files on the fly and, based on their contents, collects relevant artifacts. This makes UAC very customizable and extensible.

## Documentation

Project documentation page: [https://tclahr.github.io/uac-docs](https://tclahr.github.io/uac-docs)

## Main Features

- Runs everywhere with no dependencies (no installation required).
- Customizable and extensible collections and artifacts.
- Respects the order of volatility during artifacts collection.
- Collects information from processes running without a binary on disk.
- Extracts information from files and directories to create a bodyfile (including enhanced file attributes for ext4).
- Hashes running processes and executable files.
- Collects user and system configuration files and logs.
- Collects artifacts from applications.
- Acquires volatile memory from Linux systems using Microsoft's [avml](https://github.com/microsoft/avml) tool.

## Supported Operating Systems

UAC runs on any Unix-like system (regardless the processor architecture). All UAC needs is shell :)

- AIX
- Android
- ESXi
- FreeBSD
- Linux
- macOS
- NetBSD
- NetScaler
- OpenBSD
- Solaris

## Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) before submitting a Pull Request to the project.

## Community Support

For general help using UAC, please refer to the [official UAC documentation page](https://tclahr.github.io/uac-docs). For additional help, you can use one of the channels to ask a question:

- [Discord](https://discord.com/invite/digitalforensics) (For live discussion with the community and UAC team)
- [GitHub](https://github.com/tclahr/uac/issues) (Bug reports and contributions)
- [Twitter](https://twitter.com/tclahr) (Get the news fast)

## License

The UAC project uses the [Apache License Version 2.0](LICENSE) software license.