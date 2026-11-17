# mklinux-packages

Builds the deb and rpm packages of an [mklinux](https://github.com/multikernel/linux)
release on GitHub Actions, for x86_64 and arm64, and attaches them to the
release page. It lives apart from the kernel repo so that the kernel tree
carries no CI.

## Building a release

Once the tag is pushed and its release page exists in `multikernel/linux`:

```
gh workflow run build.yml --repo multikernel/mklinux-packages -f tag=v7.0-mk5
```

Add `-f publish=false` to only build; the packages are then kept as
workflow artifacts. A published run uploads the packages and a `SHA256SUMS`
file to the release and replaces the `## Install` section of its notes.

## One-time setup

The publish job needs a secret named `LINUX_RELEASE_TOKEN`: a fine-grained
personal access token limited to `multikernel/linux` with read and write
access to Contents.

```
gh secret set LINUX_RELEASE_TOKEN --repo multikernel/mklinux-packages
```

The repo has to be public for the hosted runners to be free.

## Configs

- `configs/x86_64.config`, `configs/arm64.config`: the generic kernel
  configs of Ubuntu 26.04, unmodified. `scripts/update-base-configs.sh`
  refreshes them.
- `configs/mklinux.config`, `configs/mklinux-<arch>.config`: what mklinux
  changes on top. `scripts/make-config.sh` merges them and fails when an
  option does not survive `olddefconfig`.

Debug info is off because a build with DWARF does not fit on a hosted
runner's disk. There is therefore no `-dbg` package and no BTF.

## Running the steps by hand

```
scripts/make-config.sh x86_64 /path/to/linux
scripts/build-packages.sh /path/to/linux out
scripts/install-notes.sh out
```
