#!/usr/bin/env bash

setup_suite() {
    export CQFD_CACHE="$BATS_SUITE_TMPDIR"
    export CQFD_PROMPT=no
    export cqfd_docker="${CQFD_DOCKER:-docker}"
    PROJECT_ROOT="$(cd "$BATS_CWD/.." && pwd)"
    export PROJECT_ROOT
    export PATH="$BATS_SUITE_TMPDIR/.local/bin:$PATH"
    mkdir -p "$BATS_SUITE_TMPDIR/.local/bin"
    cp -a "$PROJECT_ROOT/cqfd" "$BATS_SUITE_TMPDIR/.local/bin/cqfd$CQFD_COMPAT"
    if [ -n "$CQFD_COMPAT" ]; then
        ln -sf "cqfd$CQFD_COMPAT" "$BATS_SUITE_TMPDIR/.local/bin/cqfd"
    fi
    ln -sf cqfd "$BATS_SUITE_TMPDIR/.local/bin/linux-amd64-cqfd"
    ln -sf cqfd "$BATS_SUITE_TMPDIR/.local/bin/linux-arm64-cqfd"
    cp -a "$PROJECT_ROOT/tests/test_data/." "$BATS_SUITE_TMPDIR/."
    cd "$BATS_SUITE_TMPDIR/" || exit 1
}
