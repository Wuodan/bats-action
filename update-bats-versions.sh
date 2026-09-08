#!/usr/bin/env bash
set -eu

repo_owner="${1:?Usage: $0 <repo-owner>}"
script_dir="$(cd "$(dirname "$0")" && pwd)"
versions_file="$script_dir/bats-versions.sh"
temp_dir="$(mktemp -d)"

declare -a api_curl_args=(
  --fail
  --silent
  --show-error
  --location
  --retry 4
  --retry-connrefused
)

if [ -n "${GITHUB_TOKEN:-}" ]; then
  api_curl_args+=(--header "Authorization: Bearer $GITHUB_TOKEN")
fi

resolve_repository() {
  local repo="$1"
  local variable_prefix="$2"
  local release
  local tag
  local version
  local archive
  local sha256

  release="$(curl "${api_curl_args[@]}" \
    "https://api.github.com/repos/$repo/releases/latest")"
  tag="$(printf '%s' "$release" \
    | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n 1)"

  case "$tag" in
    v*) version="${tag#v}" ;;
    *)
      echo "Failed to resolve a v-prefixed release tag for $repo" >&2
      exit 1
      ;;
  esac

  archive="$temp_dir/${repo##*/}.tar.gz"
  curl --fail --silent --show-error --location \
    --retry 4 --retry-connrefused --output "$archive" \
    "https://github.com/$repo/archive/refs/tags/$tag.tar.gz"

  if command -v sha256sum >/dev/null; then
    sha256="$(sha256sum "$archive")"
  elif command -v shasum >/dev/null; then
    sha256="$(shasum -a 256 "$archive")"
  else
    echo "Could not find sha256sum or shasum" >&2
    exit 1
  fi
  sha256="${sha256%% *}"
  rm -f "$archive"

  printf -v "${variable_prefix}_VERSION" '%s' "$version"
  printf -v "${variable_prefix}_SHA256" '%s' "$sha256"
  echo "$repo: $version" >&2
}

require_assignment() {
  local variable="$1"
  local matches

  matches="$(grep -c "^${variable}=" "$versions_file" || true)"
  if [ "$matches" -ne 1 ]; then
    echo "Expected exactly one $variable assignment in $versions_file" >&2
    exit 1
  fi
}

require_assignment BATS_VERSION
require_assignment BATS_SHA256
require_assignment SUPPORT_VERSION
require_assignment SUPPORT_SHA256
require_assignment ASSERT_VERSION
require_assignment ASSERT_SHA256
require_assignment DETIK_VERSION
require_assignment DETIK_SHA256
require_assignment FILE_VERSION
require_assignment FILE_SHA256

resolve_repository "$repo_owner/bats-core" BATS
resolve_repository "$repo_owner/bats-support" SUPPORT
resolve_repository "$repo_owner/bats-assert" ASSERT
resolve_repository "$repo_owner/bats-detik" DETIK
resolve_repository "$repo_owner/bats-file" FILE

sed -i.bak \
  -e "s/^BATS_VERSION=.*/BATS_VERSION=\"$BATS_VERSION\"/" \
  -e "s/^BATS_SHA256=.*/BATS_SHA256=\"$BATS_SHA256\"/" \
  -e "s/^SUPPORT_VERSION=.*/SUPPORT_VERSION=\"$SUPPORT_VERSION\"/" \
  -e "s/^SUPPORT_SHA256=.*/SUPPORT_SHA256=\"$SUPPORT_SHA256\"/" \
  -e "s/^ASSERT_VERSION=.*/ASSERT_VERSION=\"$ASSERT_VERSION\"/" \
  -e "s/^ASSERT_SHA256=.*/ASSERT_SHA256=\"$ASSERT_SHA256\"/" \
  -e "s/^DETIK_VERSION=.*/DETIK_VERSION=\"$DETIK_VERSION\"/" \
  -e "s/^DETIK_SHA256=.*/DETIK_SHA256=\"$DETIK_SHA256\"/" \
  -e "s/^FILE_VERSION=.*/FILE_VERSION=\"$FILE_VERSION\"/" \
  -e "s/^FILE_SHA256=.*/FILE_SHA256=\"$FILE_SHA256\"/" \
  "$versions_file"

rm -f "$versions_file.bak"
rmdir "$temp_dir"
