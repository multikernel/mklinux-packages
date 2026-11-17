#!/bin/bash
# Refresh configs/{x86_64,arm64}.config from the newest generic kernel of an
# Ubuntu release. Usage: update-base-configs.sh [suite], default resolute.
set -euo pipefail

suite=${1:-resolute}
configs=$(dirname "$(realpath "$0")")/../configs
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fetch() {
	local deb_arch=$1 mirror=$2 name=$3 path=

	for pocket in "$suite-updates" "$suite"; do
		path=$(curl -fsSL "$mirror/dists/$pocket/main/binary-$deb_arch/Packages.xz" | xz -dc |
			grep -E '^Filename: .*/linux-modules-[0-9.]+-[0-9]+-generic_' |
			cut -d' ' -f2 | sort -V | tail -1)
		[ -n "$path" ] && break
	done
	[ -n "$path" ] || { echo "no generic kernel for $deb_arch in $suite" >&2; return 1; }

	echo "$name: $(basename "$path")"
	curl -fsSL -o "$tmp/modules.deb" "$mirror/$path"
	dpkg-deb --fsys-tarfile "$tmp/modules.deb" |
		tar -xO --wildcards './boot/config-*' > "$configs/$name.config"
	rm "$tmp/modules.deb"
}

fetch amd64 http://archive.ubuntu.com/ubuntu x86_64
fetch arm64 http://ports.ubuntu.com/ubuntu-ports arm64
