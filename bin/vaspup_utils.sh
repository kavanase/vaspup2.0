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

# Convert sci-form numbers (e.g. 1e-05) to plain decimal, since bc cannot parse them.
sci2dec() {
    printf "%.10f" "$1"
}

# Sum the atom counts on line 7 of a CONTCAR/POSCAR.
count_atoms() {
    sed '7q;d' "$1" | awk '{sum=0; for (i=1; i<=NF; i++) { sum+= $i } print sum}'
}

# Warn if electronic self-consistency was not reached (NELM iterations hit) for a calculation.
# Usage: check_nelm <folder> <name>
check_nelm() {
    local folder="$1" name="$2" nelm n_iter
    nelm=$(grep NELM "$folder/OUTCAR" | awk '{print $3}' | head -1 | tr -d ";")
    n_iter=$(grep Iteration "$folder/OUTCAR" | awk '{print $4}' | tail -1 | tr -d ")")
    if [ "$n_iter" == "$nelm" ]; then
        echo -e "Electronic self-consistency was not reached for ${name} (i.e. NELM reached),\nconvergence results likely unreliable."
    fi
}
