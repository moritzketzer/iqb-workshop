#!/usr/bin/env bash
# Extract only cited BibTeX entries from a global bibliography.
# Usage: ./extract-refs.sh <global.bib> <output.bib> <qmd-files...>
#
# Scans .qmd files for @citekey patterns, then extracts matching entries
# (with balanced braces) from the global bib. Produces a small, committable
# bibliography containing only what the project actually cites.

set -euo pipefail

global_bib="$1"; shift
output_bib="$1"; shift
qmd_files=("$@")

if [[ ! -f "$global_bib" ]]; then
  echo "Global bib not found: $global_bib (skipping)" >&2
  exit 0
fi

# 1. Collect unique citation keys from all qmd files
mapfile -t keys < <(
  grep -ohE '@[a-zA-Z][a-zA-Z0-9_:-]+' "${qmd_files[@]}" \
    | sed 's/^@//' \
    | sort -u
)

# 2. Build a grep pattern for entry headers
#    Matches lines like: @article{keyName,
pattern=$(printf '\\{%s,' "${keys[@]}" | sed 's/,$//')
# Fallback: also try without trailing comma (last entry edge case)

# 3. Extract matching entries using awk (handles nested braces)
#    Pass keys as a single space-separated string
key_str="${keys[*]}"

awk -v key_str="$key_str" '
BEGIN {
  n = split(key_str, arr, " ")
  for (i = 1; i <= n; i++) wanted[arr[i]] = 1
  printing = 0
  depth = 0
}
/^@/ && !printing {
  line = $0
  # strip @type{  to get the key
  sub(/^@[a-zA-Z]+\{/, "", line)
  sub(/,.*/, "", line)
  gsub(/[ \t]/, "", line)
  if (line in wanted) {
    printing = 1
    depth = 0
  }
}
printing {
  print
  for (i = 1; i <= length($0); i++) {
    c = substr($0, i, 1)
    if (c == "{") depth++
    else if (c == "}") depth--
  }
  if (depth <= 0) {
    printing = 0
    print ""
  }
}
' "$global_bib" > "$output_bib"

count=$(grep -c '^@' "$output_bib" 2>/dev/null || echo 0)
echo "Extracted $count entries → $output_bib" >&2
