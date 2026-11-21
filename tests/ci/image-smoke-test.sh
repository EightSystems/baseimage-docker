#!/bin/sh
# Smoke tests for baseimage-docker images.
#
# Mounted into the container at runtime, so no image changes required:
#   docker run --rm \
#     -v "$PWD/tests/ci/image-smoke-test.sh:/smoke-test.sh:ro" \
#     -e ALPINE_VERSION=3.24 \
#     --entrypoint /bin/sh <image> /smoke-test.sh

set -eu

ALPINE_VERSION="${ALPINE_VERSION:-}"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

pass() {
    echo "PASS: $*"
}

echo "== baseimage-smoke-test =="
echo "alpine=$ALPINE_VERSION"

if [ -n "$ALPINE_VERSION" ]; then
    actual="$(cut -d. -f1,2 /etc/alpine-release)"
    [ "$actual" = "$ALPINE_VERSION" ] || fail "Alpine mismatch: expected $ALPINE_VERSION, got $actual"
    pass "Alpine $actual"
fi

for bin in \
    /sbin/my_init \
    /usr/bin/python3 \
    /usr/bin/runsvdir \
    /usr/bin/sv \
    /usr/bin/runsvchdir \
    /usr/sbin/syslog-ng \
    /usr/sbin/crond \
    /usr/sbin/sshd \
    /sbin/setuser; do
    [ -x "$bin" ] || fail "missing executable: $bin"
done
command -v ldd >/dev/null 2>&1 || fail "ldd not found in PATH"
pass "required binaries"

grep -q 'python3' /sbin/my_init || fail "my_init missing python3 shebang"
/sbin/my_init --help >/dev/null 2>&1 || fail "my_init --help failed"
pass "my_init"

[ -d /etc/my_init.d ] || fail "missing /etc/my_init.d"
[ -x /etc/my_init.d/10_syslog-ng.init ] || fail "missing syslog init script"
[ -x /etc/my_init.post_shutdown.d/10_syslog-ng.shutdown ] || fail "missing syslog shutdown script"
[ -d /etc/service ] || fail "missing /etc/service"
[ -x /etc/service/cron/run ] || fail "missing cron runit script"
[ -x /etc/service/sshd/run ] || fail "missing sshd runit script"
[ -e /etc/service/sshd/down ] || fail "sshd must be disabled by default"
if [ -d /etc/service/supervisord ]; then
    [ -x /etc/service/supervisord/run ] || fail "missing supervisord runit script"
    [ -x /usr/bin/supervisord ] || fail "supervisord service installed without binary"
fi
pass "init/service layout"

[ -d /etc/container_environment ] || fail "missing /etc/container_environment"
[ -e /etc/container_environment.sh ] || fail "missing /etc/container_environment.sh"
[ -e /etc/container_environment.json ] || fail "missing /etc/container_environment.json"
pass "container environment"

[ ! -e /bd_build ] || fail "build directory left in image"
pass "cleanup"

scanned=0
broken=0
for dir in /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /bin /sbin; do
    [ -d "$dir" ] || continue
    for binary in "$dir"/*; do
        [ -f "$binary" ] && [ -x "$binary" ] || continue
        magic="$(head -c 4 "$binary" 2>/dev/null | od -An -tx1 | tr -d ' \n')"
        [ "$magic" = "7f454c46" ] || continue

        scanned=$((scanned + 1))
        ldd_output="$(ldd "$binary" 2>&1)" || true
        case "$ldd_output" in
            *"not found"*|*"Error relocating"*|*"undefined symbol"*)
                echo "$ldd_output" >&2
                echo "  ^ $binary" >&2
                broken=$((broken + 1))
                ;;
        esac
    done
done

[ "$scanned" -gt 0 ] || fail "no ELF binaries found to scan"
[ "$broken" -eq 0 ] || fail "$broken binary(ies) with missing libraries/symbols"
pass "dynamic linker ($scanned binaries)"

echo "ALL CHECKS PASSED"
