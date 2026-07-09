#!/usr/bin/env bash

set -euo pipefail

source_root="${1:?source root path is required}"

if [[ "${RUNNER_OS:-}" == "Windows" ]]; then
  source_root="$(echo "${source_root}" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\L\1|')"
fi

echo "${source_root}"
