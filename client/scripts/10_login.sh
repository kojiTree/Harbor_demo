#!/usr/bin/env bash
set -euo pipefail

required_env=(HARBOR_REGISTRY HARBOR_USERNAME HARBOR_PASSWORD)
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

echo "Logging in to ${HARBOR_REGISTRY} with ORAS..."
printf '%s' "$HARBOR_PASSWORD" | oras login "$HARBOR_REGISTRY" --plain-http -u "$HARBOR_USERNAME" --password-stdin
echo "Login successful."
