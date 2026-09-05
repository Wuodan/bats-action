#!/usr/bin/env bash
set -eu

repo="${1:?Usage: $0 <repo> <version> <tempdir>}"
version_input="${2:?Usage: $0 <repo> <version> <tempdir>}"

declare -a curl_args=( --retry 4 --retry-connrefused )
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_args+=( -H "Authorization: token $GITHUB_TOKEN" )
fi

version="$version_input"
if [[ -z "$version" ]] || [[ "$version" == "latest" ]]; then
  version=$(curl -fsSL "${curl_args[@]}" \
    "https://api.github.com/repos/${repo}/releases/latest" \
    | grep '"tag_name"' | head -n 1 | cut -d '"' -f 4)
  if [[ -z "$version" ]]; then
    echo "Failed to resolve latest release for ${repo}" >&2
    exit 1
  fi
fi
[[ "$version" == v* ]] && version="${version:1}"

printf '%s' "${version}"
