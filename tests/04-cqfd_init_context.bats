#!/usr/bin/env bats
#
# validate the behavior of project.build_context

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

@test "run cqfd init without using build_context should not use context directory" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='! test -e /tmp/cqfdrc-build_context'," -i .cqfdrc

    run cqfd init
    assert_success
    run cqfd
    assert_success
}

@test "run cqfd init using build_context should use the context directory" {
    cp .cqfd/docker/Dockerfile.build_context .cqfd/docker/Dockerfile
    cp cqfdrc-build_context .cqfdrc
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='test -e /tmp/cqfdrc-build_context'," -i .cqfdrc

    run cqfd init
    assert_success
    run cqfd
    assert_success
}
