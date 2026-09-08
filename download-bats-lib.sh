#!/usr/bin/env bash
set -eu

repo="${1:?Usage: $0 <repo> <version> <tempdir>}"
version="${2:?Usage: $0 <repo> <version> <tempdir>}"
tempdir="${3:?Usage: $0 <repo> <version> <tempdir>}"
script_dir="$(cd "$(dirname "$0")" && pwd)"
. "$script_dir/bats-versions.sh"

case "$repo:$version" in
  "bats-core/bats-core:$BATS_VERSION") expected_sha256="$BATS_SHA256" ;;
  "bats-core/bats-support:$SUPPORT_VERSION") expected_sha256="$SUPPORT_SHA256" ;;
  "bats-core/bats-assert:$ASSERT_VERSION") expected_sha256="$ASSERT_SHA256" ;;
  "bats-core/bats-detik:$DETIK_VERSION") expected_sha256="$DETIK_SHA256" ;;
  "bats-core/bats-file:$FILE_VERSION") expected_sha256="$FILE_SHA256" ;;
  *)
    echo "No checksum configured for ${repo} v${version}" >&2
    exit 1
    ;;
esac

url="https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz"
archive="${tempdir}.tar.gz"

echo "Downloading $url to $tempdir" >&2
mkdir -p "$(dirname "$archive")"
curl --fail --silent --show-error --location \
  --retry 4 --retry-connrefused --output "$archive" "$url"

if command -v sha256sum >/dev/null; then
  actual_sha256="$(sha256sum "$archive")"
elif command -v shasum >/dev/null; then
  actual_sha256="$(shasum -a 256 "$archive")"
else
  echo "Could not find sha256sum or shasum" >&2
  rm -f "$archive"
  exit 1
fi
actual_sha256="${actual_sha256%% *}"

if [ "$actual_sha256" != "$expected_sha256" ]; then
  echo "Checksum mismatch for $url" >&2
  echo "Expected: $expected_sha256" >&2
  echo "Actual:   $actual_sha256" >&2
  rm -f "$archive"
  exit 1
fi

mkdir -p "$tempdir"
tar xzf "$archive" -C "$tempdir" --strip-components 1
rm -f "$archive"

echo "${repo} v${version} downloaded to ${tempdir}" >&2
