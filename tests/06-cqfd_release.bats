#!/usr/bin/env bats
#
# validate the behavior of release command

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
    files=(a/cqfd_a.txt a/b/c/cqfd_c.txt a/b/cqfd_b.txt)
    export CTEST=foobar
}

teardown() {
    cp -f .cqfdrc.orig .cqfdrc
}

# set .cqfdrc from .cqfdrc.orig with extra lines appended to the [build] section
set_cqfdrc() {
    cp -f .cqfdrc.orig .cqfdrc
    printf '%s\n' "$@" >>.cqfdrc
}

@test "run cqfd release without files parameter should fail" {
    rm -f .cqfdrc

    run cqfd release
    assert_failure
}

@test "run cqfd release with a files parameter should pass" {
    set_cqfdrc "files=\"${files[*]}\""

    run cqfd release
    assert_success
}

@test "run cqfd release should generate orgname-project.tar.xz tarball archive by default" {
    run tar tf cqfd-test.tar.xz
    assert_success
}

@test "run cqfd release should preserve pathnames in tarball archive" {
    run tar tf cqfd-test.tar.xz
    assert_success
    for f in "${files[@]}"; do
        assert_line "$f"
    done

    # cleanup
    make clean
    rm cqfd-test.tar.xz
}

@test "run cqfd release with tar_transform=no should preserve pathnames in tarball archive" {
    set_cqfdrc "files=\"${files[*]}\"" "tar_transform=no"

    run cqfd release
    assert_success
    run tar tf cqfd-test.tar.xz
    assert_success
    for f in "${files[@]}"; do
        assert_line "$f"
    done

    # cleanup
    make clean
    rm cqfd-test.tar.xz
}

@test "run cqfd release with tar_transform=yes should not preserve pathnames in tarball archive" {
    set_cqfdrc "files=\"${files[*]}\"" "tar_transform=yes"

    run cqfd release
    assert_success
    run tar tf cqfd-test.tar.xz
    assert_success
    for f in "${files[@]}"; do
        assert_line "${f##*/}"
    done

    # cleanup
    make clean
    rm cqfd-test.tar.xz
}

@test "run cqfd release with tar_transform=true should not preserve pathnames in tarball archive" {
    set_cqfdrc "files=\"${files[*]}\"" "tar_transform=true"

    run cqfd release
    assert_success
    run tar tf cqfd-test.tar.xz
    assert_success
    for f in "${files[@]}"; do
        assert_line "${f##*/}"
    done

    # cleanup
    make clean
    rm cqfd-test.tar.xz
}

@test "run cqfd release with tar_options=-h should follows symlinks in tarball archive" {
    set_cqfdrc "files=\"a/cqfd_a.txt link.txt\"" "tar_options=-h"

    run cqfd release -c "&& ln -s a/cqfd_a.txt link.txt"
    assert_success
    mkdir "$BATS_SUITE_TMPDIR/output"
    run tar xf cqfd-test.tar.xz -C "$BATS_SUITE_TMPDIR/output"
    assert_success
    # link.txt is not a symlink and does not differ from cqfd_a.txt
    run test -L "$BATS_SUITE_TMPDIR/output/link.txt"
    assert_failure
    run diff "$BATS_SUITE_TMPDIR/output/a/cqfd_a.txt" "$BATS_SUITE_TMPDIR/output/link.txt"
    assert_success

    # cleanup
    make clean
    rm link.txt cqfd-test.tar.xz
    rm -R "$BATS_SUITE_TMPDIR/output"
}

@test "run cqfd release with archive=cqfd-%D3-\$CTEST.tar.xz should template tarball archive filename (RFC3339 date)" {
    d3="$(date --rfc-3339='date')"
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%D3-$CTEST.tar.xz'

    run cqfd release
    assert_success
    run tar tf "cqfd-$d3-foobar.tar.xz"
    assert_success

    # cleanup
    make clean
    rm "cqfd-$d3-foobar.tar.xz"
}

@test "run cqfd release with archive=cqfd-%Gh-\$CTEST.tar.xz should template tarball archive filename (git short hash of last commit)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%Gh-$CTEST.tar.xz'

    run cqfd release
    assert_success
    # shellcheck disable=SC2012
    run ls -1 cqfd-*-foobar.tar.xz
    assert_success
    assert_line --regexp "^cqfd-([[:xdigit:]]{4,40}|unset)-foobar.tar.xz$"
    run tar tf cqfd-*-foobar.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd-*-foobar.tar.xz
}

@test "run cqfd release with archive=cqfd-%GH-\$CTEST.tar.xz should template tarball archive filename (git long hash of last commit)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%GH-$CTEST.tar.xz'

    run cqfd release
    assert_success
    # shellcheck disable=SC2012
    run ls -1 cqfd-*-foobar.tar.xz
    assert_success
    assert_line --regexp "^cqfd-([[:xdigit:]]{40}|unset)-foobar.tar.xz$"
    run tar tf cqfd-*-foobar.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd-*-foobar.tar.xz
}

@test "run cqfd release with archive=cqfd-%Du-\$CTEST.tar.xz should template tarball archive filename (Unix timestamp)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%Du-$CTEST.tar.xz'

    run cqfd release
    assert_success
    # shellcheck disable=SC2012
    run ls -1 cqfd-*-foobar.tar.xz
    assert_success
    assert_line --regexp "^cqfd-[[:digit:]]{1,20}-foobar.tar.xz$"
    run tar tf cqfd-*-foobar.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd-*-foobar.tar.xz
}

@test "run cqfd release with archive=cqfd-%Cf-\$CTEST.tar.xz should template tarball archive filename (current cqfd flavor name unset)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%Cf-$CTEST.tar.xz'

    run cqfd release
    assert_success
    run tar tf cqfd--foobar.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd--foobar.tar.xz
}

@test "run cqfd release with flavor foo and archive=cqfd-%Cf-\$CTEST.tar.xz should template tarball archive filename (current cqfd flavor name set)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%Cf-$CTEST.tar.xz'

    run cqfd -b foo release
    assert_success
    run tar tf cqfd-foo.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd-foo.tar.xz
}

@test "run cqfd release with flavor bar archive=cqfd-%Cf-\$CTEST.tar.xz should template tarball archive filename (current cqfd flavor name set)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%Cf-$CTEST.tar.xz'

    run cqfd -b bar release
    assert_success
    run tar tf cqfd-bar.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd-bar.tar.xz
}

@test "run cqfd release with archive=cqfd-%Po-\$CTEST.tar.xz should template tarball archive filename (value of the project.org configuration key)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%Po-$CTEST.tar.xz'

    run cqfd release
    assert_success
    run tar tf cqfd-cqfd-foobar.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd-cqfd-foobar.tar.xz
}

@test "run cqfd release with archive=cqfd-%Pn-\$CTEST.tar.xz should template tarball archive filename (value of the project.name configuration key)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%Pn-$CTEST.tar.xz'

    run cqfd release
    assert_success
    run tar tf cqfd-test-foobar.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd-test-foobar.tar.xz
}

@test "run cqfd release with archive=cqfd-%%-\$CTEST.tar.xz should template tarball archive filename (litteral '%' sign)" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-%%-$CTEST.tar.xz'

    run cqfd release
    assert_success
    run tar tf cqfd-%-foobar.tar.xz
    assert_success

    # cleanup
    make clean
    rm cqfd-%-foobar.tar.xz
}

@test "run cqfd release with archive=cqfd-\$CTEST.tar.gz should generate a gzipped tarball archive" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-$CTEST.tar.gz'

    run cqfd release
    assert_success
    run tar ztf "cqfd-$CTEST.tar.gz"
    assert_success

    # cleanup
    make clean
    rm "cqfd-$CTEST.tar.gz"
}

@test "run cqfd release with archive=cqfd-\$CTEST.zip should generate a zip archive" {
    # shellcheck disable=SC2016
    set_cqfdrc "files=\"${files[*]}\"" 'archive=cqfd-$CTEST.zip'

    run cqfd release
    assert_success
    run unzip -l "cqfd-$CTEST.zip"
    assert_success

    # cleanup
    make clean
    rm "cqfd-$CTEST.zip"
}

@test "run cqfd release with a non-existing file or directory in files parameter should fail" {
    # shellcheck disable=SC2016
    set_cqfdrc 'files="ThisFileDoesNotExist.txt"' 'archive=cqfd-$CTEST.zip'

    run cqfd release
    assert_failure

    # cleanup
    make clean
}

@test "run cqfd release should resolve globbing pathnames in files parameter" {
    # shellcheck disable=SC2016
    set_cqfdrc 'files=".cq*rc Ma*"' 'archive=cqfd-$CTEST.tar.xz'

    run cqfd release
    assert_success
}

# the generated archive should contain our expanded globs
@test "run cqfd release should archive globbing pathnames in archive" {
    run tar tf "cqfd-$CTEST.tar.xz"
    assert_success
    assert_line ".cqfdrc"
    assert_line "Makefile"

    # cleanup
    make clean
    rm "cqfd-$CTEST.tar.xz"
}

@test "run cqfd release with unsupported archive format in archive parameter should fail" {
    # shellcheck disable=SC2016
    set_cqfdrc 'files=".cq*rc Ma*"' 'archive=cqfd-$CTEST.tar.zst'

    run cqfd release
    assert_failure

    # cleanup
    make clean
}

@test "run cqfd with option --release should pass" {
    # shellcheck disable=SC2016
    set_cqfdrc 'files=".local/bin/cqfd"' 'archive=cqfd-$CTEST.tar.xz'

    run cqfd --release
    assert_success
}

@test "run cqfd with option --release should generate orgname-\$CTEST.tar.xz tarball archive by default" {
    run tar tf "cqfd-$CTEST.tar.xz"
    assert_success

    # cleanup
    make clean
    rm "cqfd-$CTEST.tar.xz"
}
