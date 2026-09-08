#!/usr/bin/env bash
set -eu

repo="${1:?Usage: $0 <repo> <version> <tempdir>}"
version="${2:?Usage: $0 <repo> <version> <tempdir>}"
tempdir="${3:?Usage: $0 <repo> <version> <tempdir>}"

url="https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz"
echo "Downloading $url to $tempdir" >&2
mkdir -p "$tempdir"
curl --fail --silent --show-error --location \
  --retry 4 --retry-connrefused "$url" \
  | tar xz -C "$tempdir" --strip-components 1
echo "${repo} v${version} downloaded to ${tempdir}" >&2
