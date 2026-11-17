#!/bin/bash
# Usage: publish.sh <tag> <dir of packages>
# Needs GH_TOKEN with contents write access to $LINUX_REPO.
set -euo pipefail

tag=$1
dir=$(realpath "$2")
repo=${LINUX_REPO:-multikernel/linux}
scripts=$(dirname "$(realpath "$0")")

cd "$dir"
shopt -s nullglob
packages=(*.deb *.rpm)
[ ${#packages[@]} -gt 0 ] || { echo "no packages in $dir" >&2; exit 1; }

sha256sum "${packages[@]}" > SHA256SUMS
gh release upload "$tag" --repo "$repo" --clobber "${packages[@]}" SHA256SUMS

notes=$(mktemp)
gh release view "$tag" --repo "$repo" --json body --jq .body | sed '/^## Install$/,$d' > "$notes"
"$scripts/install-notes.sh" "$dir" >> "$notes"
gh release edit "$tag" --repo "$repo" --notes-file "$notes"
