#!/usr/bin/env bats
#
# validate the behavior of cqfd with Dockerfile

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
    mv -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile
    rm -rf .cqfd-symlink

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

@test "run cqfd with ENTRYPOINT in Dockerfile should pass" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='true'," -i .cqfdrc
    cat <<EOF >>.cqfd/docker/Dockerfile
ENTRYPOINT ["false"]
EOF

    run cqfd init
    assert_success
    run cqfd
    assert_success
}

@test "run cqfd with WORKDIR in Dockerfile should pass" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='pwd'," -i .cqfdrc
    cat <<EOF >>.cqfd/docker/Dockerfile
WORKDIR /mnt
EOF

    run cqfd init
    assert_success
    run cqfd
    assert_success
    assert_line "$PWD"
}

@test "run cqfd with USER in Dockerfile should pass" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='id -un'," -i .cqfdrc
    cat <<EOF >>.cqfd/docker/Dockerfile
USER nobody
EOF

    run cqfd init
    assert_success
    run cqfd
    assert_success
    assert_line "nobody"
}

@test "run cqfd init without a Dockerfile in alternate directory should fail" {
    mkdir -p .cqfd-symlink/docker

    run cqfd -d .cqfd-symlink init
    assert_failure
}

@test "run cqfd init with a symlinked Dockerfile in alternate directory should pass" {
    mkdir -p .cqfd-symlink/docker
    ln -sf ../../.cqfd/docker/Dockerfile .cqfd-symlink/docker/Dockerfile

    run cqfd -d .cqfd-symlink init
    assert_success
}
