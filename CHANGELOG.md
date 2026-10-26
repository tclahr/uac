# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

### Artifacts

- `files/browser/firefox.yaml`: Added support for Firefox 147+ path changes (`.config/mozilla/firefox`) while retaining the legacy path (`.mozilla/firefox`) for compatibility and ESR releases [freebsd, linux]. (by [reece394](https://github.com/reece394))

### Removed Artifacts

### Fixed

- `lib/azure_storage_sas_url_transfer.sh`: Added block blob upload for output files larger than the Azure Storage 5,000 MiB single-request limit. The output remains a single blob and is not split; `curl` is required for large files.

### Tools
