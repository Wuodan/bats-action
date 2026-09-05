#!/usr/bin/env bash
set -eu

repo="${1:?Usage: $0 <repo> <version> <tempdir>}"
version_input="${2:?Usage: $0 <repo> <version> <tempdir>}"
tempdir="${3:?Usage: $0 <repo> <version> <tempdir>}"

declare -a auth_args=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_args=( -H "Authorization: token $GITHUB_TOKEN" )
fi

version="$version_input"
if [[ -z "$version" ]] || [[ "$version" == "latest" ]]; then
  version=$(curl -fsSL --retry 4 --retry-connrefused "${auth_args[@]}" \
    "https://api.github.com/repos/${repo}/releases/latest" \
    | grep '"tag_name"' | head -n 1 | cut -d '"' -f 4)
  if [[ -z "$version" ]]; then
    echo "Failed to resolve latest release for ${repo}" >&2
    exit 1
  fi
fi
[[ "$version" == v* ]] && version="${version:1}"

url="https://api.github.com/repos/${repo}/tarball/v${version}"
echo "Downloading $url" >&2
mkdir -p "$tempdir"
curl -sL --retry 4 --retry-connrefused "${auth_args[@]}" "$url" \
  | tar xz -C "$tempdir" --strip-components 1
echo "${repo} v${version} downloaded to ${tempdir}" >&2
