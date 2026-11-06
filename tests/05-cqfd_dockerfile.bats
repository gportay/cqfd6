#!/usr/bin/env bats
#
# validate the behavior of dockerfile

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
}

teardown_file() {
    # cleanup
    rm -f Dockerfile support/docker/Dockerfile .cqfd/docker/Containerfile
    rmdir -p subdir/ support/docker 2>/dev/null || true

    mv -f .cqfdrc.orig .cqfdrc
    mv -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile

    # restore container
    cqfd init
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# $1: the path to the Dockerfile set in dockerfile
set_dockerfile() {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='grep ^PRETTY_NAME /etc/os-release'," .cqfdrc.orig >.cqfdrc
    sed -e "/\[build\]/adockerfile=\"$1\"" -i .cqfdrc
}

@test "run cqfd should use the Dockerfile set in dockerfile" {
    echo "FROM ubuntu:16.04" >Dockerfile
    set_dockerfile "Dockerfile"

    run cqfd init
    assert_success

    run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 16.04(.[[:digit:]]+)? LTS\"$"
}

@test "run cqfd from a subdirectory should use the Dockerfile set in dockerfile, relative to project directory" {
    set_dockerfile "Dockerfile"
    mkdir -p subdir

    run cqfd -C subdir
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 16.04(.[[:digit:]]+)? LTS\"$"
}

@test "run cqfd from a subdirectory should use the Dockerfile in subdirectory set in dockerfile" {
    mkdir -p support/docker
    mv Dockerfile support/docker/Dockerfile
    set_dockerfile "support/docker/Dockerfile"

    run cqfd init
    assert_success

    run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 16.04(.[[:digit:]]+)? LTS\"$"
}

@test "run cqfd from a subdirectory should use the Dockerfile in a subdirectory set in dockerfile, relative to project directory" {
    set_dockerfile "support/docker/Dockerfile"

    run cqfd -C subdir
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 16.04(.[[:digit:]]+)? LTS\"$"

    # cleanup
    rm support/docker/Dockerfile
    rmdir -p subdir/ support/docker
}

@test "run cqfd should use the Dockerfile named Containerfile set in dockerfile" {
    echo "FROM ubuntu:16.04" >.cqfd/docker/Containerfile
    set_dockerfile ".cqfd/docker/Containerfile"

    run cqfd init
    assert_success

    run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 16.04(.[[:digit:]]+)? LTS\"$"
}

@test "run cqfd should with build_context should use the context directory and the Dockerfile named Containerfile set in dockerfile" {
    echo "ADD ./cqfdrc-build_context /tmp/" >>.cqfd/docker/Containerfile
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='grep ^PRETTY_NAME /etc/os-release \&\& test -e /tmp/cqfdrc-build_context'," .cqfdrc.orig >.cqfdrc
    sed -e '/\[build\]/adockerfile=".cqfd/docker/Containerfile"' -i .cqfdrc
    sed -e '/\[project\]/abuild_context="."' -i .cqfdrc

    run cqfd init
    assert_success

    run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 16.04(.[[:digit:]]+)? LTS\"$"

    # cleanup
    rm .cqfd/docker/Containerfile
}
