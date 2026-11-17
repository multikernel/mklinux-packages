#!/bin/bash
# Usage: build-packages.sh <configured kernel source dir> <output dir>
set -euo pipefail

src=$(realpath "$1")
mkdir -p "$2"
out=$(realpath "$2")

export KBUILD_BUILD_USER=mklinux KBUILD_BUILD_HOST=github-actions

cd "$src"
# Without LOCALVERSION= a git checkout appends "+" to the release.
make -j"$(nproc)" LOCALVERSION= bindeb-pkg
make -j"$(nproc)" LOCALVERSION= binrpm-pkg

find .. -maxdepth 1 \( -name 'linux-image-*.deb' -o -name 'linux-headers-*.deb' \) \
	! -name '*-dbg_*' -exec cp -t "$out" {} +
find rpmbuild/RPMS -name 'kernel-*.rpm' ! -name '*debuginfo*' -exec cp -t "$out" {} +

ls -l "$out"
