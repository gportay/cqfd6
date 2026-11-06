#!/usr/bin/env bats
#
# validate the behavior of running docker in cqfd using host docker daemon

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
    read -r -a docker <<<"${CQFD_DOCKER:-docker}"
    if [ "${docker[-1]}" != "docker" ] || ! getent group docker | grep -q "$USER"; then
        skip "requires docker and $USER in docker group"
    fi
}

teardown() {
    cp -f .cqfdrc.orig .cqfdrc
    cp -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile
}

@test "run cqfd should execute as the host user with the cqfd docker group" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='id -Gn'," .cqfdrc.orig >.cqfdrc

    CQFD_BIND_DOCKER_SOCK=true run cqfd
    assert_success
    assert_output --regexp "(^|[[:blank:]])cqfd([[:blank:]]|$)"
}

@test "run cqfd should not run docker using host docker daemon by default" {
    cp -f .cqfd/docker/Dockerfile.doutofd .cqfd/docker/Dockerfile
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='docker run --rm ubuntu:24.04 cat /etc/os-release'," .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success
    run cqfd
    assert_failure
}

@test "run cqfd should run docker using host docker daemon" {
    cp -f .cqfd/docker/Dockerfile.doutofd .cqfd/docker/Dockerfile
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='docker run --rm ubuntu:24.04 cat /etc/os-release'," .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success
    CQFD_BIND_DOCKER_SOCK=true run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 24.04(.[[:digit:]]+)? LTS\"$"
}

@test "run cqfd should run docker using host docker daemon if bind_docker_sock is set" {
    cp -f .cqfd/docker/Dockerfile.doutofd .cqfd/docker/Dockerfile
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='docker run --rm ubuntu:24.04 cat /etc/os-release'\nbind_docker_sock='true'," .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success
    run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 24.04(.[[:digit:]]+)? LTS\"$"
}
