#!/bin/bash
set -Eeuo pipefail

# Which engines to run.
# Defaults: master vs feature; if you only have ./mchess, just point both to it.
ENGINE_A_CMD="${ENGINE_A_CMD:-./mchess_master uci}"
ENGINE_B_CMD="${ENGINE_B_CMD:-./mchess_feature uci}"
ENGINE_A_NAME="${ENGINE_A_NAME:-master}"
ENGINE_B_NAME="${ENGINE_B_NAME:-feature}"

# Basic tournament config (overridable via env)
GAMES="${GAMES:-2000}"
TC="${TC:-5+0.05}"
THREADS_PER_ENGINE="${THREADS_PER_ENGINE:-2}"
CONCURRENCY="${CONCURRENCY:-8}"
HASH_MB="${HASH_MB:-64}"

RESULT_DIR="${RESULT_DIR:-/root/results}"
LOG_DIR="$RESULT_DIR/logs"
mkdir -p "$RESULT_DIR" "$LOG_DIR"

FASTCHESS="./fastchess"

# Extract the actual binary paths from the cmd strings (first word)
ENGINE_A_BIN=$(printf '%s\n' "$ENGINE_A_CMD" | awk '{print $1}')
ENGINE_B_BIN=$(printf '%s\n' "$ENGINE_B_CMD" | awk '{print $1}')

chmod +x "$ENGINE_A_BIN" "$ENGINE_B_BIN" "$FASTCHESS"

echo "=== [$(date)] Starting fastchess tournament ==="
echo "Games: $GAMES, TC: $TC"
echo "Engine A: $ENGINE_A_NAME ($ENGINE_A_CMD)"
echo "Engine B: $ENGINE_B_NAME ($ENGINE_B_CMD)"
echo "Threads/engine: $THREADS_PER_ENGINE, Concurrency: $CONCURRENCY, Hash: ${HASH_MB}MB"

MCHESS_INIT=$(cat <<EOT
uci
setoption name Threads value $THREADS_PER_ENGINE
setoption name Hash value $HASH_MB
isready
EOT
)

"$FASTCHESS" \
  -engine cmd="$ENGINE_A_CMD" name="$ENGINE_A_NAME" init="$MCHESS_INIT" \
  -engine cmd="$ENGINE_B_CMD" name="$ENGINE_B_NAME" init="$MCHESS_INIT" \
  -games "$GAMES" \
  -concurrency "$CONCURRENCY" \
  -pgnout "$RESULT_DIR/match.pgn" \
  -logdir "$LOG_DIR" \
  > "$RESULT_DIR/tournament.log" 2>&1

echo "=== [$(date)] Tournament completed ==="
echo "Results in: $RESULT_DIR"
