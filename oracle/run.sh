#!/bin/sh
# Oracle harness (matz/spinel#1753 condition #2): replay each snapshot-
# gated flow through the REAL multi_json gem and diff against the snapshots
# frozen from the compiled mirror. Proves the real gem derives identical
# output from identical flows — surface parity with zero hand-authored
# expectations.
#
# Usage: sh oracle/run.sh          (from the repo root)
# Needs: ruby with the multi_json gem installed (+ any live service it drives).
#
# Freeze a snapshot from the mirror (stdout only), once per flow:
#   ruby -I . oracle/<flow>.rb > test/<flow>_test.rb.expected
set -e
OUTDIR=build/oracle
mkdir -p "$OUTDIR"

fails=0
ran=0
# TODO: list each flow whose *_test.rb.expected snapshot is committed.
for flow in smoke; do
  ran=$((ran + 1))
  # Compare STDOUT only — the flow's deterministic output is the
  # contract. stderr (kept in .err for debugging) carries unrelated
  # rubygems/env warnings that would otherwise fail a valid parity run.
  ruby "oracle/$flow.rb" > "$OUTDIR/$flow.out" 2> "$OUTDIR/$flow.err" || true
  if diff -u "test/${flow}_test.rb.expected" "$OUTDIR/$flow.out" > "$OUTDIR/$flow.diff" 2>&1; then
    echo "ok   $flow"
    rm -f "$OUTDIR/$flow.diff"
  else
    echo "FAIL $flow (see $OUTDIR/$flow.diff)"
    fails=$((fails + 1))
  fi
done
echo "$((ran - fails))/$ran flows match the real multi_json"
[ $fails -eq 0 ]
