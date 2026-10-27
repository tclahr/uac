# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

- Failed transfers to S3 (Amazon, Google and IBM), Amazon S3 presigned URL and Azure Storage SAS URL are now retried up to 3 times. Azure Storage SAS URL uploads in blocks retry only the failed block instead of restarting the whole upload.

### Artifacts

- `files/browser/firefox.yaml`: Added support for Firefox 147+ path changes (`.config/mozilla/firefox`) while retaining the legacy path (`.mozilla/firefox`) for compatibility and ESR releases [freebsd, linux]. (by [reece394](https://github.com/reece394))

### Removed Artifacts

### Fixed

- Fixed `--azure-storage-sas-url` transfers failing with HTTP 413 (Request Entity Too Large) for output files larger than 5000 MiB. Files larger than 500 MiB are now uploaded in blocks using Put Block and Put Block List.
- Fixed HTTP-based transfers being reported as successful on HTTP errors (e.g. 403, 413) when running in verbose mode, which could lead to the local output file being deleted when `--delete-local-on-successful-transfer` was used.

### Tools
