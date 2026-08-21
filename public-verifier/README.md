# AZAGOHRATH Public Cryptographic Verification

This directory contains the public and reproducible verification procedure for the AZAGOHRATH Authorship Proof repository.

The verification process checks:

- signed current Git commit
- historical signed release tag
- Evidence Root SHA-256 integrity
- detached ED25519 Evidence Root signature
- public signing identity
- absence of tracked private signing keys

## Public signing identity

    AZAGOHRATH

## Run

From the repository root:

    ./public-verifier/verify.sh

A successful execution ends with:

    PUBLIC CRYPTOGRAPHIC VERIFICATION PASSED

The verification procedure uses only public cryptographic material contained in this repository.

No private signing key is required for verification.
