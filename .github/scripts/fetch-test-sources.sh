#!/usr/bin/env bash

set -euo pipefail

target_root="${1:?target root is required}"
api_url="https://api.github.com/repos"

declare -a auth_args=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_args=(-H "Authorization: token ${GITHUB_TOKEN}")
fi

fetch_repo() {
  local repo="$1"
  local version="$2"
  local dest_dir="$3"

  rm -rf "${dest_dir}"
  mkdir -p "${dest_dir}"
  curl -fsSL --retry 4 --retry-connrefused "${auth_args[@]}" \
    "${api_url}/${repo}/tarball/v${version}" \
    | tar xz -C "${dest_dir}" --strip-components 1
}

mkdir -p "${target_root}"

fetch_repo "bats-core/bats-support" "${SUPPORT_VERSION:?}" "${target_root}/bats-support"
fetch_repo "bats-core/bats-assert" "${ASSERT_VERSION:?}" "${target_root}/bats-assert"
fetch_repo "bats-core/bats-detik" "${DETIK_VERSION:?}" "${target_root}/bats-detik"
fetch_repo "bats-core/bats-file" "${FILE_VERSION:?}" "${target_root}/bats-file"
