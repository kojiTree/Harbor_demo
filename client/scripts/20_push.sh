#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CLIENT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
ARTIFACT_DIR="${CLIENT_ROOT}/demo-artifact"
OUT_DIR="${CLIENT_ROOT}/out"
ARTIFACT_TYPE="${ARTIFACT_TYPE:-application/vnd.demo.files.v1+json}"

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

if [[ ! -d "$ARTIFACT_DIR" ]]; then
  echo "Artifact directory not found: ${ARTIFACT_DIR}" >&2
  exit 1
fi

files=()
while IFS= read -r file; do
  files+=("$file")
done < <(cd "$ARTIFACT_DIR" && find . -maxdepth 1 -type f -printf "%f\n" | sort)

if (( ${#files[@]} == 0 )); then
  echo "No files found in ${ARTIFACT_DIR} to push." >&2
  exit 1
fi

if [[ -d "$OUT_DIR" ]]; then
  echo "Cleaning previous output directory: ${OUT_DIR}"
  rm -rf "$OUT_DIR"
fi

REF="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPO}:${HARBOR_TAG}"
echo "Pushing artifact to ${REF}"
echo "Artifact type: ${ARTIFACT_TYPE}"

(
  cd "$ARTIFACT_DIR"
  oras push --plain-http --artifact-type "$ARTIFACT_TYPE" "$REF" "${files[@]}"
)
echo "Push completed."

