#!/usr/bin/env bats
#
# validate the behavior of cqfd entrypoint

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig

    cp -f .cqfd/docker/Dockerfile.missing_dependencies .cqfd/docker/Dockerfile
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='true'," .cqfdrc.orig >.cqfdrc
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
    mv -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile

    # restore container
    cqfd init
}

setup() {
    load 'test_helper/common-setup'
    _common_setup

    read -r -a cqfd_docker <<<"${CQFD_DOCKER:-docker}"
    if [ "$CQFD_RUN_WITH_SUDO" = true ]; then
        cqfd_docker=(sudo "${cqfd_docker[@]}")
    fi

    if [ "${cqfd_docker[-1]}" = "podman" ]; then
        skip "not supported by podman"
    fi
}

@test "run cqfd without useradd and groupadd commands should fail" {
    run cqfd init
    assert_success

    run cqfd
    assert_failure
}

@test "run cqfd with useradd and groupadd commands should pass" {
    echo 'RUN apk add shadow' >>.cqfd/docker/Dockerfile

    run cqfd init
    assert_success

    run cqfd --verbose
    assert_success
}

@test "run cqfd without CQFD_SHELL command should fail" {
    run cqfd init
    assert_success

    CQFD_SHELL=/bin/bash run cqfd --verbose
    assert_failure
}

@test "run cqfd with CQFD_SHELL command should pass" {
    echo 'RUN apk add bash' >>.cqfd/docker/Dockerfile

    run cqfd init
    assert_success

    CQFD_SHELL=/bin/bash run cqfd --verbose
    assert_success
}

@test "run cqfd with su command should pass" {
    run cqfd init
    assert_success

    run cqfd --verbose
    assert_success
    assert_line --partial 'Using "su"'
}

@test "run cqfd with sudo command should pass" {
    echo 'RUN apk add sudo' >>.cqfd/docker/Dockerfile

    run cqfd init
    assert_success

    run cqfd --verbose
    assert_success
    assert_line --partial 'Using "sudo"'
}

@test "run cqfd should create the user" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='grep \"^$USER:x:$(id -u):$(id -g)::$HOME:/bin/sh\$\" /etc/passwd'," .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success

    run cqfd
    assert_success
}

@test "run cqfd should create and own the user's home directory" {
    echo 'RUN sed "/DEFAULT_HOME/s,yes,no," -i /etc/login.defs' >>.cqfd/docker/Dockerfile
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='test -w $HOME'," .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success

    CQFD_NO_USER_SSH_CONFIG=true CQFD_NO_USER_GIT_CONFIG=true run cqfd
    assert_success
}

@test "run cqfd should execute as the host user" {
    if ! getent group docker | grep -q "$USER"; then
        skip "$USER not in docker group"
    fi

    sed -e "/\[build\]/,/^$/s,^command=.*$,command='id'," .cqfdrc.orig >.cqfdrc

    run cqfd
    assert_success
    assert_line "uid=$(id -u)($USER) gid=$(id -g)($USER) groups=$(id -u)($USER)"
}

@test "run cqfd should not execute sudo without authentication" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='sudo env'," .cqfdrc.orig >.cqfdrc

    run cqfd </dev/null
    assert_failure
}

@test "run cqfd with CQFD_SUDO_NOPASSWD should execute sudo without authentication" {
    if ! getent group docker | grep -q "$USER"; then
        skip "$USER not in docker group"
    fi

    sed -e "/\[build\]/,/^$/s,^command=.*$,command='sudo env'," .cqfdrc.orig >.cqfdrc

    CQFD_SUDO_NOPASSWD=true run cqfd </dev/null
    assert_success
}

@test "run cqfd with sudo should preserve umask" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='umask'," .cqfdrc.orig >.cqfdrc

    run cqfd
    assert_success
    umask="$output"

    CQFD_SUDO_NOPASSWD=true run cqfd
    assert_success
    assert_equal "$output" "$umask"
}

@test "run cqfd with ancient su should run su -c" {
    echo "FROM ubuntu:16.04" >.cqfd/docker/Dockerfile

    run cqfd init
    assert_success

    run cqfd --verbose
    assert_success
    assert_line --partial 'Using "su" to execute command'
}

@test "run cqfd with recent su should run su --session-command" {
    echo "FROM ubuntu:24.04" >.cqfd/docker/Dockerfile

    run cqfd init
    assert_success

    run cqfd --verbose
    assert_success
    assert_line --partial 'Using "su" to execute session command'
}

@test "run cqfd with sudo should run sudo" {
    echo "ENV DEBIAN_FRONTEND=noninteractive" >>.cqfd/docker/Dockerfile
    echo "RUN apt-get update && apt-get install -y --no-install-recommends sudo" >>.cqfd/docker/Dockerfile

    run cqfd init
    assert_success

    run cqfd --verbose
    assert_success
    assert_line --partial 'Using "sudo" to execute command'
}
