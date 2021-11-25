# UAC (Unix-like Artifacts Collector)

UAC is a Live Response collection tool for Incident Response that makes use of built-in tools to automate the collection of Unix-like systems artifacts. It was created to facilitate and speed up data collection, and depend less on remote support during incident response engagements.

UAC reads artifacts files on the fly and, based on their contents, collects relevant artifacts using one of the 5 available collectors. This makes UAC very customizable and extensible.

## Documentation

Project documentation page: [https://tclahr.github.io/uac-docs](https://tclahr.github.io/uac-docs)

## Main Features

- Fast and continuously tested
- Runs everywhere with no dependencies (no installation required)
- Customizable and extensible collections and artifacts
- Respects the order of volatility during artifacts collection
- Collects information from processes running without a binary on disk
- Extracts information from files and directories to create a bodyfile (including enhanced file attributes for ext4)
- Hashes running processes and executable files
- Acquires volatile memory from Linux systems using avml tool

## Supported Operating Systems

UAC runs on any Unix-like system (regardless the processor architecture). All UAC needs is shell.

- AIX
- Android
- FreeBSD
- Linux
- macOS
- NetBSD
- NetScaler
- OpenBSD
- Solaris

## License

The UAC project uses the [Apache License Version 2.0](LICENSE) software license.