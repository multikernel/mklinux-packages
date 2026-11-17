#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y -q --no-install-recommends \
	build-essential bc bison flex cpio kmod rsync python3 zstd \
	libssl-dev libelf-dev libdw-dev dwarves \
	debhelper fakeroot rpm
