#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CLIENT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
ARTIFACT_DIR="${CLIENT_ROOT}/demo-artifact"

required_env=(HARBOR_REGISTRY HARBOR_PROJECT HARBOR_REPO HARBOR_TAG HARBOR_USERNAME HARBOR_PASSWORD)
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

missing_cmds=()
require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    missing_cmds+=("$1")
  fi
}

require_cmd "oras"

if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
  missing_cmds+=("sha256sum (or shasum -a 256)")
fi

if (( ${#missing_cmds[@]} )); then
  echo "Missing required commands: ${missing_cmds[*]}" >&2
  exit 1
fi

if [[ ! -d "$ARTIFACT_DIR" ]]; then
  echo "Artifact directory not found: ${ARTIFACT_DIR}" >&2
  exit 1
fi

if ! ls "$ARTIFACT_DIR"/*.txt "$ARTIFACT_DIR"/*.json "$ARTIFACT_DIR"/README.md >/dev/null 2>&1; then
  echo "Artifact directory is missing expected files (hello.txt, metadata.json, README.md)." >&2
  exit 1
fi

REF="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPO}:${HARBOR_TAG}"
echo "Environment and tool checks passed."
echo "Target reference: ${REF}"
