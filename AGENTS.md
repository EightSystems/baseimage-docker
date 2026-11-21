# AGENTS.md

## Build and verify

- No local test/lint/typecheck suite. CI runs `tests/ci/image-smoke-test.sh` against a locally loaded image before each multiarch push; it checks init/runit binaries, service layout, cleanup, and dynamic linker health (no PHP checks).
- Build from the repo root. `Dockerfile` defaults to Alpine 3.24; CI passes explicit version args. Use the same form for local builds:
  `docker build -t 8sistemas/baseimage:alpine-3.24 --build-arg BASE_IMAGE=alpine:3.24 --build-arg ALPINE_VERSION=3.24 -f Dockerfile .`
- `image/` has no Dockerfile. README examples using `docker build ... image/` and `install-tools.sh` are stale; trust the root `Dockerfile` and `.github/workflows`.
- CI builds multiarch (`linux/amd64`, `linux/arm64`) via QEMU/Buildx and publishes to `ghcr.io/eightsystems/baseimage-docker` and `8sistemas/baseimage`.
- Commit messages containing `[skipci]` or `[noci]` disable workflow builds.

## Release and matrix

- Workflow files are the executable source of truth for supported versions and tags; README may lag.
- Plain image matrix: Alpine 3.20, 3.23, and 3.24. Laravel workflows cover the same Alpines; PHP matrix is per workflow (3.24: 8.5/8.6).
- Trivy scans every published image with `scanners: vuln`: SARIF report (LOW/MEDIUM/HIGH/CRITICAL, exit 0), HIGH/CRITICAL gate (exit 1), and uploaded report. Secret scanning stays off because the image intentionally ships the insecure SSH keypair. Anchore remains on 3.24 only.
- Laravel images reuse the same root `Dockerfile`; PHP/variant/xdebug selection is encoded in the `BASE_IMAGE` build arg and output tag.
- Workflows run on `main` pushes, manual dispatch, and a twice-monthly schedule.

## Image internals

- `Dockerfile` copies `image/` to `/bd_build`, then runs `prepare.sh -> system_services.sh -> utilities.sh -> cleanup.sh`. Installer scripts assume `/bd_build/buildconfig` and absolute `/bd_build/...` paths.
- Entry point is `/sbin/my_init` from `image/bin/my_init`: it starts syslog via `/etc/my_init.d/10_syslog-ng.init`, then runit via `runsvdir -P /etc/service`. Syslog shutdown runs from `/etc/my_init.post_shutdown.d/10_syslog-ng.shutdown`.
- Service installers live in `image/services/*/*.sh` and are invoked only from `image/system_services.sh`. `DISABLE_SYSLOG`, `DISABLE_SSH`, `DISABLE_CRON`, and `DISABLE_SUPERVISORD` build args default to `0` in `image/buildconfig`.
- Do not hardcode `/sbin` for runit tools. Alpine 3.24 installs them under `/usr/sbin`; `prepare.sh` aliases `sv`, `runsvdir`, and `runsvchdir` into `/usr/bin` via `command -v`.
- The build runs `apk upgrade --no-cache` after package installs so rebuilt images pick up Alpine security fixes.
- Runit services need executable `/etc/service/<name>/run` scripts that stay in the foreground. `my_init` ignores non-executable startup scripts, so preserve executable bits in git.
- SSH ships disabled via `/etc/service/sshd/down` with a public insecure key for development; preserve that default. New Alpine versions need a package check in `image/services/sshd/sshd.sh` (3.20/3.23/3.24 require `openssh-server-common-openrc`).
- `image/bin/install_clean` is leftover Debian/apt code, copied but unused by the Alpine build. Do not introduce apt usage.
