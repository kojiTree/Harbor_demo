#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CLIENT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
ARTIFACT_DIR="${CLIENT_ROOT}/demo-artifact"
OUT_DIR="${CLIENT_ROOT}/out"

checksum() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    echo "No checksum command found (sha256sum or shasum -a 256 required)." >&2
    exit 1
  fi
}

if [[ ! -d "$ARTIFACT_DIR" ]]; then
  echo "Artifact directory not found: ${ARTIFACT_DIR}" >&2
  exit 1
fi

if [[ ! -d "$OUT_DIR" ]]; then
  echo "Output directory not found: ${OUT_DIR}. Run pull first." >&2
  exit 1
fi

status=0
for src in "${ARTIFACT_DIR}"/*; do
  [[ -f "$src" ]] || continue
  filename=$(basename "$src")
  dest="${OUT_DIR}/${filename}"

  if [[ ! -f "$dest" ]]; then
    echo "Missing file in out/: ${dest}" >&2
    status=1
    continue
  fi

  src_hash=$(checksum "$src")
  dest_hash=$(checksum "$dest")

  if [[ "$src_hash" != "$dest_hash" ]]; then
    echo "Mismatch: ${filename}" >&2
    echo "  source: ${src_hash}" >&2
    echo "  pulled: ${dest_hash}" >&2
    status=1
  else
    echo "Verified: ${filename}"
  fi
done

if [[ "$status" -ne 0 ]]; then
  echo "Verification failed." >&2
else
  echo "All files verified successfully."
fi

exit "$status"
