#!/usr/bin/env bash
# Watches images/dags for PDF changes and converts them to SVG.
# Runs an initial pass on start, then watches for changes.
# Usage: ./pdf-svg-watcher.sh [--once]
#   --once  Run a single pass and exit (no watching)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WATCH_DIR="$SCRIPT_DIR"

convert_pdf_to_svg() {
    local pdf_file="$1"
    local svg_file="${pdf_file%.pdf}.svg"
    local rel_path="${pdf_file#"$WATCH_DIR"/}"

    if [[ ! -f "$svg_file" ]] || [[ "$pdf_file" -nt "$svg_file" ]]; then
        echo "Converting: $rel_path"
        if pdf2svg "$pdf_file" "$svg_file"; then
            echo "  → ${svg_file#"$WATCH_DIR"/}"
        else
            echo "  ✗ Failed to convert $rel_path" >&2
        fi
    fi
}

run_pass() {
    echo "Scanning for PDFs in $WATCH_DIR..."
    local count=0
    while IFS= read -r -d '' pdf_file; do
        convert_pdf_to_svg "$pdf_file"
        ((count++)) || true
    done < <(find "$WATCH_DIR" -type f -name '*.pdf' -print0)
    echo "Checked $count PDF(s)."
}

watch_loop() {
    echo "Watching for PDF changes (Ctrl+C to stop)..."
    fswatch -0 --event Created --event Updated --event Renamed \
        --include '\.pdf$' --exclude '.*' "$WATCH_DIR" |
    while IFS= read -r -d '' pdf_file; do
        [[ -f "$pdf_file" ]] && convert_pdf_to_svg "$pdf_file"
    done
}

# Check dependencies
for cmd in pdf2svg fswatch; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd not found. Install with: brew install $cmd" >&2
        exit 1
    fi
done

# Main
run_pass
echo ""

if [[ "${1:-}" == "--once" ]]; then
    echo "Single pass complete."
else
    watch_loop
fi