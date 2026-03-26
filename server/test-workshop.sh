#!/usr/bin/env bash
# Automated workshop verification — runs on the VPS via SSH.
# Usage: scp test-workshop.sh root@your-server-ip:/tmp/ && ssh root@your-server-ip bash /tmp/test-workshop.sh

set -uo pipefail

# Derive paths from systemd unit (always up to date)
WRAPPER_BIN=$(systemctl cat rstudio-server 2>/dev/null | grep -oP '/nix/store/[^"]+/bin/rserver' | head -1)
WRAPPER="${WRAPPER_BIN%/bin/rserver}"
FIX_LIBS="$WRAPPER/fix_libs.R"

# Find Rscript: nix links the wrapper's rsession to the real R
RSESSION="$WRAPPER/bin/rsession"
R_STORE=$(grep -oP '/nix/store/[a-zA-Z0-9]+-R-[0-9.]+' "$RSESSION" 2>/dev/null | head -1)
if [ -z "$R_STORE" ]; then
  # Fallback: find the actual R (not .drv, -wrapper, -tex, .tar.gz)
  R_STORE=$(ls -d /nix/store/*-R-[0-9]* 2>/dev/null | grep -vE '\.(drv|gz)$|-wrapper|-tex' | head -1)
fi
RSCRIPT="$R_STORE/bin/Rscript"

TEST_USER="pearl"
PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL: $1"; }

# Run R with wrapper library paths
run_r() {
  local user="$1"
  shift
  su - "$user" -c "R_PROFILE_USER='$FIX_LIBS' $RSCRIPT $*" 2>&1
}

echo "=== Workshop Server Tests ==="
echo "Rscript: $RSCRIPT"
echo "fix_libs: $FIX_LIBS"
echo ""

# --- 1. Services ---
echo "[1/7] Services"
systemctl is-active --quiet rstudio-server && pass "rstudio-server active" || fail "rstudio-server not active"
systemctl is-active --quiet claim-server && pass "claim-server active" || fail "claim-server not active"

# --- 2. HTTP endpoints ---
echo "[2/7] HTTP endpoints"
code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
[ "$code" = "200" ] && pass "claim page (200)" || fail "claim page ($code)"

code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8787)
[ "$code" = "302" ] && pass "RStudio login redirect (302)" || fail "RStudio ($code)"

code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/gallery)
[ "$code" = "200" ] && pass "gallery page (200)" || fail "gallery page ($code)"

curl -s http://localhost/gallery | grep -q "DAG Gallery" && pass "gallery title present" || fail "gallery title missing"
curl -s http://localhost | grep -q "Causal Inference" && pass "claim page title present" || fail "claim page title missing"
curl -s -X POST -d "name=pearl&lookup=1" http://localhost | grep -q "changeme" && pass "password shown after claim" || fail "password not shown"

# --- 3. Locale ---
echo "[3/7] Locale"
locale_output=$(su - "$TEST_USER" -c "locale" 2>&1)
if echo "$locale_output" | grep -q "UTF-8"; then
  pass "locale UTF-8"
else
  fail "locale not UTF-8: $(echo "$locale_output" | head -1)"
fi

# --- 4. Exercise files ---
echo "[4/7] Exercise files in /home/$TEST_USER"
for f in hello-world.R causal-quartet.R helpers.R dagitty-open-science.R dagitty-helpers.R multilevel-confounding.R multilevel-helpers.R multilevel-data.rds; do
  [ -f "/home/$TEST_USER/$f" ] && pass "$f exists" || fail "$f missing"
done
for f in dag-collider.png dag-confounder.png dag-mediator.png dag-mbias.png; do
  [ -f "/home/$TEST_USER/$f" ] && pass "$f exists" || fail "$f missing"
done

# --- 5. R packages ---
echo "[5/7] R packages"
for pkg in tidyverse broom quartets lavaan dagitty jsonlite ggplot2 lme4 brms; do
  if run_r "$TEST_USER" "-e \"library($pkg)\"" &>/dev/null; then
    pass "library($pkg)"
  else
    fail "library($pkg)"
  fi
done

# --- 6. Exercise scripts parse ---
echo "[6/7] Exercise scripts parse"
if run_r "$TEST_USER" "-e \"setwd('/home/$TEST_USER'); source('dagitty-helpers.R')\"" &>/dev/null; then
  pass "dagitty-helpers.R sources OK"
else
  fail "dagitty-helpers.R source error"
fi

if run_r "$TEST_USER" "-e \"setwd('/home/$TEST_USER'); source('helpers.R')\"" &>/dev/null; then
  pass "helpers.R sources OK"
else
  fail "helpers.R source error"
fi

# --- 7. Gallery submission (end-to-end) ---
echo "[7/7] Gallery submission"
rm -f /var/lib/gallery/test_*

run_r "$TEST_USER" "-e \"
setwd('/home/$TEST_USER')
source('dagitty-helpers.R')
library(dagitty)
open_science_dag <- dagitty('dag {
  \\\"Open Data\\\" [exposure]
  Citations [outcome]
  Novelty -> Citations
  Rigour -> Citations
  Rigour -> \\\"Open Data\\\"
  \\\"Open Data\\\" -> Citations
}')
exposures(open_science_dag) <- 'Open Data'
outcomes(open_science_dag) <- 'Citations'
df <- simulate_open_science()
submit('test')
\"" &>/dev/null

ls /var/lib/gallery/test_*_meta.json &>/dev/null && pass "meta.json written" || fail "meta.json missing"
ls /var/lib/gallery/test_*_dag.png &>/dev/null && pass "dag.png written" || fail "dag.png missing"
ls /var/lib/gallery/test_*_bias.png &>/dev/null && pass "bias.png written" || fail "bias.png missing"

# Check metadata includes adjustment_sets field
if grep -q "adjustment_sets" /var/lib/gallery/test_*_meta.json 2>/dev/null; then
  pass "meta.json has adjustment_sets"
else
  fail "meta.json missing adjustment_sets"
fi

curl -s http://localhost/gallery | grep -q "test" && pass "gallery shows submission" || fail "gallery missing submission"

# Clean up test submission
rm -f /var/lib/gallery/test_*

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
