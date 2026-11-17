#!/bin/bash
# Usage: make-config.sh <x86_64|arm64> <kernel source dir> [make args...]
# Writes .config in the kernel source dir (or in O=, when given).
set -euo pipefail

arch=$1
src=$(realpath "$2")
shift 2
configs=$(dirname "$(realpath "$0")")/../configs

fragments=("$configs/mklinux.config")
[ -f "$configs/mklinux-$arch.config" ] && fragments+=("$configs/mklinux-$arch.config")

out=$src
for arg in "$@"; do
	case $arg in O=*) out=${arg#O=} ;; esac
done

cd "$src"
scripts/kconfig/merge_config.sh -m -O "$out" "$configs/$arch.config" "${fragments[@]}" >/dev/null
make "$@" olddefconfig >/dev/null

# olddefconfig silently drops what it cannot satisfy, so check the result.
status=0
while read -r line; do
	case $line in
	CONFIG_*=*)
		grep -qxF -- "$line" "$out/.config" || { echo "missing: $line" >&2; status=1; } ;;
	"# CONFIG_"*" is not set")
		sym=${line#\# }; sym=${sym% is not set}
		! grep -q "^$sym=" "$out/.config" || { echo "still set: $sym" >&2; status=1; } ;;
	esac
done < <(cat "${fragments[@]}")
exit $status
