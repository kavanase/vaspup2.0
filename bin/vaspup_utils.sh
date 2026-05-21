#!/bin/bash
# vaspup2.0 - Seán Kavanagh (sean.kavanagh.19@ucl.ac.uk), 2023
# Shared helper functions, meant to be sourced by the other vaspup2.0 scripts.

# Portable in-place sed: GNU sed uses "-i", while BSD/macOS sed needs "-i ''".
sedi() {
    if sed --version >/dev/null 2>&1; then
        sed -i "$@"      # GNU sed
    else
        sed -i '' "$@"   # BSD / macOS sed
    fi
}
