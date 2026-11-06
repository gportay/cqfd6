#!/usr/bin/env bats
#
# validate the use case of ssh-agent

bats_require_minimum_version 1.5.0

setup_file() {
    # backup Dockerfile and .cqfdrc
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
    cp -f .cqfdrc .cqfdrc.orig

    echo "FROM ubuntu:24.04" >.cqfd/docker/Dockerfile
    echo "RUN apt-get -y update && apt-get -y install openssh-client" >>.cqfd/docker/Dockerfile
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='test -S \$SSH_AUTH_SOCK \&\& env'," .cqfdrc.orig >.cqfdrc
    chmod 600 cqfd-test_ed25519
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

    if ! command -v ssh-agent; then
        skip "ssh-agent: command not found"
    fi
}

@test "run cqfd with running host ssh-agent should forward socket to container" {
    run cqfd init
    assert_success

    run ssh-agent cqfd
    assert_success
    assert_line --regexp "^SSH_AUTH_SOCK=/tmp/ssh-[[:alnum:]]+/agent\.[[:digit:]]+$"
}

@test "run cqfd with running host and no private keys added ssh-agent should fail" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='ssh-add -L'," -i .cqfdrc

    run ssh-agent cqfd
    assert_failure
}

@test "run cqfd with running host and a private key added ssh-agent should pass" {
    run --separate-stderr ssh-agent sh -c "ssh-add cqfd-test_ed25519 && exec cqfd"
    assert_success
    assert_output "$(cat cqfd-test_ed25519.pub)"
}

@test "run cqfd with CQFD_NO_SSH_AUTH_SOCK=true and running host ssh-agent should forward socket to container" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='env'," -i .cqfdrc

    CQFD_NO_SSH_AUTH_SOCK=true run ssh-agent cqfd
    assert_success
    refute_line --regexp "^SSH_AUTH_SOCK=/tmp/ssh-[[:alnum:]]+/agent\.[[:digit:]]+$"
}
