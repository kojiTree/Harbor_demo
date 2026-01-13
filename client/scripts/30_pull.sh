#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CLIENT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
OUT_DIR="${CLIENT_ROOT}/out"
ARTIFACT_TYPE="${ARTIFACT_TYPE:-application/vnd.demo.files.v1+json}"

required_env=(HARBOR_REGISTRY HARBOR_PROJECT HARBOR_REPO HARBOR_TAG)
missing_env=()
for var in "${required_env[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    missing_env+=("$var")
  fi
done

if (( ${#missing_env[@]} )); then
  echo "Missing required environment variables: ${missing_env[*]}" >&2
  exit 1
fi

REF="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPO}:${HARBOR_TAG}"

mkdir -p "$OUT_DIR"
echo "Pulling ${REF} into ${OUT_DIR}"
oras pull --plain-http --output "$OUT_DIR" "$REF"

echo "Pulled files:"
ls -l "$OUT_DIR"
