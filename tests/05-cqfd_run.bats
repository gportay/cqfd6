#!/usr/bin/env bats
#
# validate the behavior of run command

setup_file() {
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
}

teardown_file() {
    mv -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile

    # restore container
    cqfd init
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd run with run without arguments should pass" {
    run cqfd run
    assert_success

    run test -e a/cqfd_a.txt
    assert_success

    # cleanup
    rm a/cqfd_a.txt
}

@test "run cqfd run with outdated Dockerfile should fail" {
    cat .cqfd/docker/Dockerfile.orig - <<EOF2 >.cqfd/docker/Dockerfile
RUN echo $RANDOM
EOF2

    run cqfd run
    assert_failure

    # cleanup
    make clean
    cp -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile
}

@test "run cqfd run with argument should run command string" {
    run cqfd run "touch foobar"
    assert_success

    run test -f foobar
    assert_success

    # cleanup
    rm foobar
}

@test "run cqfd run with arguments should run as a command string" {
    run cqfd run touch foobar
    assert_success

    run test -f foobar
    assert_success

    # cleanup
    rm foobar
}

@test "run cqfd run with arguments cannot preserve arguments" {
    # shellcheck disable=SC2016
    run cqfd run /bin/sh -c 'printf "0=$0,*=$*,#=$#"' zero one two three
    assert_failure 2
}
