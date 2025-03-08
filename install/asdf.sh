#!/usr/bin/env bash

set -euo pipefail

# stolen from https://github.com/rbenv/ruby-build/pull/631/files#diff-fdcfb8a18714b33b07529b7d02b54f1dR942
sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
  git ls-remote --tags --refs https://github.com/asdf-vm/asdf.git |
    grep -o 'refs/tags/.*' |
    cut -d/ -f3- |
    sed 's/^v//' |
    sort_versions
}

version_check() {
  local -r version=$1
  local -r min_version="0.16.0"

  if [ "$(printf "%s\n" "$min_version" "$version" | sort -V | head -n1)" != "$min_version" ]; then
    echo >&2 "err: only support to install asdf >= v0.16.0"
    exit 1
  fi
}

get_arch() {
  case $(uname -m) in
  arm64 | aarch64) echo "arm64" ;;
  *386*) echo "386" ;;
  *) echo "amd64" ;;
  esac
}

get_platform() {
  uname | tr '[:upper:]' '[:lower:]'
}

install() {
  local -r version=${ASDF_VERSION:-"$(list_all_versions | tail -n1)"}
  local -r platform=$(get_platform)
  local -r arch=$(get_arch)

  # ${var/#<character_to_find>/<character_to_replace>} has similar approach with
  # echo $1 | sed 's/^v//'
  version_check "${version/#v/}"

  curl -sSfL "https://github.com/asdf-vm/asdf/releases/download/v${version/#v/}/asdf-v${version/#v/}-$platform-$arch.tar.gz" -o - | tar -xz --directory="${ASDF_BIN_LOCATION:-/usr/local/bin}" asdf
}

install
