#!/bin/bash
# Usage: install-notes.sh <dir of packages>
# Prints the Install section of the release notes for the packages found.
set -euo pipefail

cd "$1"
shopt -s nullglob

cat <<'NOTES'
## Install

Packages built from this tag on GitHub Actions with the Ubuntu 26.04 generic config plus `CONFIG_MULTIKERNEL=y`, without debug info (so no BTF). They are not Secure Boot signed; modules are signed with a per-build key. Verify downloads with `sha256sum -c --ignore-missing SHA256SUMS`.
NOTES

for arch in amd64 arm64; do
	debs=(linux-image-*_"$arch".deb linux-headers-*_"$arch".deb)
	[ ${#debs[@]} -gt 0 ] || continue
	printf '\nDebian/Ubuntu (%s):\n\n```\nsudo apt install%s\n```\n' \
		"$arch" "$(printf ' ./%s' "${debs[@]}")"
done

for arch in x86_64 aarch64; do
	rpms=(kernel-[0-9]*."$arch".rpm kernel-devel-*."$arch".rpm)
	[ ${#rpms[@]} -gt 0 ] || continue
	printf '\nFedora/RHEL (%s):\n\n```\nsudo dnf install%s\n```\n' \
		"$arch" "$(printf ' ./%s' "${rpms[@]}")"
done
