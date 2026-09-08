#!/usr/bin/env bash
set -eu

script_dir="$(cd "$(dirname "$0")" && pwd)"
install_path="${INSTALL_PATH:?}"
temp_dir="$(mktemp -d)"

"$script_dir/download-bats-lib.sh" \
  bats-core/bats-core "${BATS_VERSION:?}" "$temp_dir/bats-core"

mkdir -p "$install_path"
"$temp_dir/bats-core/install.sh" "$install_path"

install_library() {
  local repository="$1"
  local version="$2"
  local source_directory="${3:-.}"

  "$script_dir/download-bats-lib.sh" \
    "bats-core/$repository" "$version" "$temp_dir/$repository"

  mkdir -p "$install_path/$repository"
  cp -R "$temp_dir/$repository/$source_directory/." \
    "$install_path/$repository/"
}

install_library bats-support "${SUPPORT_VERSION:?}"
install_library bats-assert "${ASSERT_VERSION:?}"
install_library bats-detik "${DETIK_VERSION:?}" lib
install_library bats-file "${FILE_VERSION:?}"

rm -rf "$temp_dir"
