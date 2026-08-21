#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

MANIFEST="$ROOT/SHA256SUMS.txt"
SIG="$ROOT/signatures/SHA256SUMS.txt.sig"
PUB="$ROOT/signatures/SIGNING_KEY.pub"

IDENTITY="AZAGOHRATH"
NAMESPACE="file"

echo
echo "=============================================================="
echo " AZAGOHRATH — PUBLIC AUTHORSHIP PROOF VERIFIER"
echo "=============================================================="
echo

FAIL=0

echo "[1/5] REQUIRED FILES"

for FILE in "$MANIFEST" "$SIG" "$PUB"; do
    if [[ -f "$FILE" ]]; then
        echo "✓ $(basename "$FILE")"
    else
        echo "✗ MISSING: $FILE"
        FAIL=1
    fi
done

if (( FAIL != 0 )); then
    exit 1
fi

echo
echo "[2/5] VERIFYING SHA-256 PAYLOAD"

cd "$ROOT"

if /usr/bin/shasum -a 256 -c SHA256SUMS.txt; then
    echo
    echo "✓ PAYLOAD INTEGRITY VERIFIED"
else
    echo
    echo "✗ PAYLOAD INTEGRITY FAILED"
    exit 1
fi

echo
echo "[3/5] BUILDING PUBLIC VERIFICATION IDENTITY"

ALLOWED="$(mktemp)"
trap 'rm -f "$ALLOWED"' EXIT

printf '%s %s\n' \
    "$IDENTITY" \
    "$(cat "$PUB")" \
    > "$ALLOWED"

echo "✓ PUBLIC VERIFICATION IDENTITY READY"

echo
echo "[4/5] VERIFYING ED25519 SIGNATURE"

if ssh-keygen -Y verify \
    -f "$ALLOWED" \
    -I "$IDENTITY" \
    -n "$NAMESPACE" \
    -s "$SIG" \
    < "$MANIFEST"
then
    echo
    echo "✓ CRYPTOGRAPHIC SIGNATURE VERIFIED"
else
    echo
    echo "✗ CRYPTOGRAPHIC SIGNATURE INVALID"
    exit 1
fi

echo
echo "[5/5] PUBLIC KEY INFORMATION"

ssh-keygen -lf "$PUB"

echo
echo "╔════════════════════════════════════════════════════════════╗"
echo "║        AZAGOHRATH AUTHORSHIP PROOF — VERIFIED            ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║ SHA-256 PAYLOAD         ● PASS                           ║"
echo "║ ED25519 SIGNATURE       ● PASS                           ║"
echo "║ PUBLIC KEY              ● VERIFIED                       ║"
echo "║ PRIVATE KEY REQUIRED    ● NO                             ║"
echo "║ BUNDLE INTEGRITY        ● VERIFIED                       ║"
echo "╚════════════════════════════════════════════════════════════╝"

echo
echo "✓ INDEPENDENT VERIFICATION COMPLETE"
echo
