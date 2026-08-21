#!/bin/sh
set -eu

BASE_COMMIT="0f109a6860b139479e44ec8518bbaba292ae2a75"
CERT_COMMIT="af7235e88dadcbe69a529f073ddc9ae8ffabb015"
EXPECTED_CERT_SHA="a2572a149630989a7d2b2bd43a477dc68bf581c834c2cbf9d35160ba9b1403fb"

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CERT="$ROOT/certificate/AZAGOHRATH_RELEASE_CERTIFICATE.txt"
SIG="$ROOT/certificate/AZAGOHRATH_RELEASE_CERTIFICATE.txt.sig"
PUB="$ROOT/signatures/SIGNING_KEY.pub"

echo "============================================================"
echo " AZAGOHRATH — INDEPENDENT CRYPTOGRAPHIC VERIFIER"
echo "============================================================"

echo "[1/6] REQUIRED FILES"
for F in "$CERT" "$SIG" "$PUB"; do
  [ -f "$F" ] || { echo "FAIL: missing $F"; exit 1; }
done
echo "PASS"

echo "[2/6] CERTIFICATE SHA-256"
CURRENT_CERT_SHA="$(shasum -a 256 "$CERT" | awk '{print $1}')"
echo "EXPECTED: $EXPECTED_CERT_SHA"
echo "CURRENT : $CURRENT_CERT_SHA"
[ "$CURRENT_CERT_SHA" = "$EXPECTED_CERT_SHA" ] || { echo "FAIL"; exit 1; }
echo "PASS"

echo "[3/6] DETACHED ED25519 SIGNATURE"
ALLOWED="$(mktemp)"
trap 'rm -f "$ALLOWED"' EXIT HUP INT TERM
printf "AZAGOHRATH %s\n" "$(cat "$PUB")" > "$ALLOWED"
ssh-keygen -Y verify -f "$ALLOWED" -I AZAGOHRATH -n file -s "$SIG" < "$CERT"
echo "PASS"

echo "[4/6] GIT OBJECTS"
git -C "$ROOT" cat-file -e "${BASE_COMMIT}^{commit}"
git -C "$ROOT" cat-file -e "${CERT_COMMIT}^{commit}"
echo "PASS"

echo "[5/6] COMMIT LINEAGE"
git -C "$ROOT" merge-base --is-ancestor "$BASE_COMMIT" "$CERT_COMMIT"
PARENT="$(git -C "$ROOT" rev-parse "${CERT_COMMIT}^")"
echo "EXPECTED PARENT: $BASE_COMMIT"
echo "ACTUAL PARENT  : $PARENT"
[ "$PARENT" = "$BASE_COMMIT" ] || { echo "FAIL"; exit 1; }
echo "PASS"

echo "[6/6] SIGNED GIT COMMIT"
git -C "$ROOT" verify-commit "$CERT_COMMIT"
echo "PASS"

echo "============================================================"
echo " INDEPENDENT VERIFICATION PASSED"
echo "============================================================"
echo "CERTIFICATE SHA-256  : MATCH"
echo "DETACHED ED25519     : VALID"
echo "BASE COMMIT          : PRESENT"
echo "CERTIFICATE COMMIT   : PRESENT"
echo "COMMIT LINEAGE       : VALID"
echo "SIGNED GIT COMMIT    : VALID"
echo "============================================================"
