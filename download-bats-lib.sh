#!/usr/bin/env bash
set -eu

repo="${1:?Usage: $0 <repo> <version> <tempdir>}"
version="${2:?Usage: $0 <repo> <version> <tempdir>}"
tempdir="${3:?Usage: $0 <repo> <version> <tempdir>}"

declare -a curl_args=( --retry 4 --retry-connrefused )
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_args+=( -H "Authorization: token $GITHUB_TOKEN" )
fi

url="https://api.github.com/repos/${repo}/tarball/v${version}"
echo "Downloading $url to $tempdir" >&2
mkdir -p "$tempdir"
curl -sL "${curl_args[@]}" "$url" \
  | tar xz -C "$tempdir" --strip-components 1
echo "${repo} v${version} downloaded to ${tempdir}" >&2
