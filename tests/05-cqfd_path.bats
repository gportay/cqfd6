#!/usr/bin/env bats
#
# validate the behavior of cqfd with path

setup_file() {
    # backup Dockerfile and .cqfdrc
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
    cp -f .cqfdrc .cqfdrc.orig

    sed -e '/\[build\]/apath="/opt/cqfd/bin:/usr/sbin:/usr/bin:/sbin:/bin"' .cqfdrc.orig >.cqfdrc
}

teardown_file() {
    # restore .cqfdrc and Dockerfile
    mv -f .cqfdrc.orig .cqfdrc
    mv -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile

    # restore container
    cqfd init
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

skip_if_podman() {
    # shellcheck disable=SC2154
    if [ "${cqfd_docker##* }" = "podman" ]; then
        skip "unsupported with podman"
    fi
}

@test "run cqfd run with path and busybox su -c should set PATH" {
    skip_if_podman

    cat <<EOF2 >.cqfd/docker/Dockerfile
FROM alpine:3.20
RUN apk update && apk upgrade
RUN apk add shadow
EOF2

    run cqfd init
    assert_success

    run cqfd run env
    assert_success
    assert_line "PATH=/opt/cqfd/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

@test "run cqfd run with busybox su -c should preserve umask" {
    skip_if_podman

    umask="$(cqfd --cqfdrc-file .cqfdrc.orig run "umask")"

    run cqfd run "umask"
    assert_success
    assert_output "$umask"
}

@test "run cqfd run with path and su -c should set PATH" {
    skip_if_podman

    cat <<EOF2 >.cqfd/docker/Dockerfile
FROM ubuntu:16.04
EOF2

    run cqfd init
    assert_success

    run cqfd run env
    assert_success
    assert_line "PATH=/opt/cqfd/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

@test "run cqfd run with su -c should preserve umask" {
    skip_if_podman

    umask="$(cqfd --cqfdrc-file .cqfdrc.orig run "sh -c umask")"

    run cqfd run "sh -c umask"
    assert_success
    assert_output "$umask"
}

@test "run cqfd run with path and su --session-command should set PATH" {
    skip_if_podman

    cat <<EOF2 >.cqfd/docker/Dockerfile
FROM ubuntu:24.04
EOF2

    run cqfd init
    assert_success

    run cqfd run env
    assert_success
    assert_line "PATH=/opt/cqfd/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

@test "run cqfd run with su --session-command should preserve umask" {
    skip_if_podman

    umask="$(cqfd --cqfdrc-file .cqfdrc.orig run "umask")"

    run cqfd run "umask"
    assert_success
    assert_output "$umask"
}

@test "run cqfd run with path and sudo should set PATH" {
    skip_if_podman

    cat <<EOF2 >.cqfd/docker/Dockerfile
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends sudo
EOF2

    run cqfd init
    assert_success

    run cqfd run env
    assert_success
    assert_line "PATH=/opt/cqfd/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

@test "run cqfd run with sudo should preserve umask" {
    skip_if_podman

    umask="$(cqfd --cqfdrc-file .cqfdrc.orig run "umask")"

    run cqfd run "umask"
    assert_success
    assert_output "$umask"
}

@test "run cqfd run with path and sh should set PATH" {
    cat <<EOF2 >.cqfd/docker/Dockerfile
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends sudo
USER $UID:${GROUPS[0]}
EOF2

    run cqfd init
    assert_success

    run cqfd run env
    assert_success
    assert_line "PATH=/opt/cqfd/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}
