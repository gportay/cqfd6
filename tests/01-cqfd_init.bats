#!/usr/bin/env bats
#
# validate the behavior of init command

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
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
}

teardown() {
    cp -f .cqfdrc.orig .cqfdrc
    cp -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile
}

@test "run cqfd init with a .cqfdrc file should pass" {
    run cqfd init
    assert_success
}

@test "run cqfd init with a nonexistent Dockerfile should fail" {
    sed -e "s/\[build\]/[build]\ndistro='thisshouldfail'/" .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_failure
}

@test "run cqfd init with another Dockerfile should pass" {
    sed -e "s/\[build\]/[build]\ndistro='fedora'/" .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success
}

@test "run cqfd init with same uid/gid dummy user should pass" {
    cat <<EOF2 >>.cqfd/docker/Dockerfile
RUN groupadd -og "$(id -g)" -f dummy && \\
    useradd -s /bin/bash -ou "$(id -u)" -g "$(id -g)" dummy
EOF2

    run cqfd init
    assert_success
}

@test "run cqfd init with --quiet should remain quiet" {
    cat <<EOF2 >>.cqfd/docker/Dockerfile
RUN groupadd -og "$(id -g)" -f dummy && \\
    useradd -s /bin/bash -ou "$(id -u)" -g "$(id -g)" dummy
EOF2

    run cqfd -q init
    assert_success
    assert_line --regexp --index 0 "^(sha256:)?[a-f0-9]{64}$"
}
