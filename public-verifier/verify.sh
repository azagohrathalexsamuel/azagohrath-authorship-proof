#!/bin/zsh
set -e

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

ROOTFILE="evidence-root/AZAGOHRATH_EVIDENCE_ROOT.txt"
ROOTHASH="evidence-root/AZAGOHRATH_EVIDENCE_ROOT.sha256"
ROOTSIG="evidence-root/AZAGOHRATH_EVIDENCE_ROOT.txt.sig"
ALLOWED="public-verifier/allowed_signers"

echo "============================================================"
echo " AZAGOHRATH — PUBLIC CRYPTOGRAPHIC VERIFIER"
echo "============================================================"

echo
echo "[1/5] CURRENT COMMIT"

git verify-commit HEAD
echo "PASS: SIGNED GIT COMMIT"

echo
echo "[2/5] EVIDENCE ROOT SHA-256"

EXPECTED="$(awk '{print $1}' "$ROOTHASH")"
CURRENT="$(shasum -a 256 "$ROOTFILE" | awk '{print $1}')"

echo "EXPECTED: $EXPECTED"
echo "CURRENT : $CURRENT"

[[ "$EXPECTED" == "$CURRENT" ]] || {
    echo "FAIL: SHA-256 mismatch"
    exit 1
}

echo "PASS: SHA-256 VERIFIED"

echo
echo "[3/5] EVIDENCE ROOT ED25519"

ssh-keygen -Y verify \
    -f "$ALLOWED" \
    -I AZAGOHRATH \
    -n file \
    -s "$ROOTSIG" < "$ROOTFILE"

echo "PASS: ED25519 VERIFIED"

echo
echo "[4/5] HISTORICAL RELEASE TAG"

git verify-tag authorship-proof-v1.0.0
echo "PASS: HISTORICAL SIGNED TAG VERIFIED"

echo
echo "[5/5] PRIVATE KEY SAFETY"

if git ls-files | grep -E '(^|/)(id_ed25519|id_rsa|.*\.pem|.*\.key)$' >/dev/null
then
    echo "FAIL: POSSIBLE PRIVATE KEY TRACKED"
    exit 1
fi

echo "PASS: NO PRIVATE SIGNING KEY TRACKED"

echo
echo "============================================================"
echo " PUBLIC CRYPTOGRAPHIC VERIFICATION PASSED"
echo "============================================================"

echo
echo "HEAD:"
git rev-parse HEAD

echo
echo "EVIDENCE ROOT:"
echo "$CURRENT"

echo
echo "PUBLIC SIGNING IDENTITY:"
echo "AZAGOHRATH"

echo
echo "✓ VERIFICATION COMPLETE"
