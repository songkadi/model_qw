#!/bin/bash
set -euo pipefail
shopt -s nullglob

# Collect files with 3 or 4 digit numeric extensions, sort numerically, and process
files=(models.zip.[0-9][0-9][0-9] models.zip.[0-9][0-9][0-9][0-9])
sorted=()
for pattern in "${files[@]}"; do
    for f in $pattern; do
        # ensure it's a file and extension is numeric
        if [[ -f "$f" ]]; then
            ext_raw="${f##*.}"
            if [[ "$ext_raw" =~ ^[0-9]{3,4}$ ]]; then
                sorted+=("$f")
            fi
        fi
    done
done

# Sort by numeric extension value
IFS=$'\n' sorted=( $(printf "%s\n" "${sorted[@]}" | sort -t. -k3,3n) )

for f in "${sorted[@]}"; do
    ext_raw="${f##*.}"
    # pad to 4 digits
    ext=$(printf "%04d" "$ext_raw")
    git add -- "$f"
    git commit -m "$f"
    git push -f origin HEAD:"$ext"
    echo "Pushed $f to branch $ext"
    rm "$f"
done

git push -f origin HEAD:main
