# AZAGOHRATH Independent Verification

This directory contains a standalone verification procedure for the cryptographic evidence published in this repository.

## Run

From the repository root:

```sh
./verify/verify-proof.sh
```

## The verifier checks

- SHA-256 of the release certificate
- detached ED25519 signature
- public signing key
- presence of the original base commit
- presence of the certificate commit
- direct commit lineage
- signed Git commit verification

## Security

No private signing key is required or intentionally distributed in this repository.

## Scope

A successful verification establishes cryptographic consistency between the published files, signatures, hashes, and Git history. It does not by itself constitute a legal determination of copyright ownership, identity, priority, or absolute authorship.
