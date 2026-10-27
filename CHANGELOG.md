# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

- Failed transfers to S3 (Amazon, Google and IBM), Amazon S3 presigned URL and Azure Storage SAS URL are now retried up to 3 times. Azure Storage SAS URL uploads in blocks retry only the failed block instead of restarting the whole upload.
- S3 transfers (Amazon, Google and IBM) of files larger than 500 MiB now use multipart upload when `curl` is available, so a failed part is retried without restarting the whole upload. The multipart upload is aborted on failure, so no orphan parts are left on the server.
- Failed SFTP transfers are now retried up to 3 times, resuming the partially uploaded file using `reput` (OpenSSH 6.5 or later).

### Artifacts

- `files/browser/firefox.yaml`: Added support for Firefox 147+ path changes (`.config/mozilla/firefox`) while retaining the legacy path (`.mozilla/firefox`) for compatibility and ESR releases [freebsd, linux]. (by [reece394](https://github.com/reece394))

### Removed Artifacts

### Fixed

- Fixed `--azure-storage-sas-url` transfers failing with HTTP 413 (Request Entity Too Large) for output files larger than 5000 MiB. Files larger than 500 MiB are now uploaded in blocks using Put Block and Put Block List.
- Fixed `--s3-provider amazon` and `--s3-provider ibm` transfers failing for output files larger than 5 GiB, the maximum size of a single PUT request.
- Fixed SFTP transfers being reported as successful when the upload failed (e.g. permission denied, disk full), as `sftp` exit status was always 0 when commands were read from stdin. This could lead to the local output file being deleted when `--delete-local-on-successful-transfer` was used.
- Fixed HTTP-based transfers being reported as successful on HTTP errors (e.g. 403, 413) when running in verbose mode, which could lead to the local output file being deleted when `--delete-local-on-successful-transfer` was used.

### Tools
