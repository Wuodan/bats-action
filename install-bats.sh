#!/usr/bin/env bash
set -eu

script_dir="$(cd "$(dirname "$0")" && pwd)"
install_path="${INSTALL_PATH:?}"
temp_dir="$(mktemp -d)"
"$script_dir/download-bats-repos.sh" "$temp_dir"

mkdir -p "$install_path"
"$temp_dir/bats-core/install.sh" "$install_path"

install_library() {
  local repository="$1"
  local source_directory="$2"

  mkdir -p "$install_path/$repository"
  cp -R "$temp_dir/$repository/$source_directory/." \
    "$install_path/$repository/"
}

install_library bats-support .
install_library bats-assert .
install_library bats-detik lib
install_library bats-file .

rm -rf "$temp_dir"
