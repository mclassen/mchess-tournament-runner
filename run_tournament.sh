#!/bin/bash
set -Eeuo pipefail

# Basic tournament config (overridable via env)
GAMES="${GAMES:-2000}"
TC="${TC:-5+0.05}"
THREADS_PER_ENGINE="${THREADS_PER_ENGINE:-2}"
CONCURRENCY="${CONCURRENCY:-8}"
HASH_MB="${HASH_MB:-64}"

RESULT_DIR="${RESULT_DIR:-/root/results}"
LOG_DIR="$RESULT_DIR/logs"
mkdir -p "$RESULT_DIR" "$LOG_DIR"

ENGINE_A="./mchess"
ENGINE_B="./mchess"
FASTCHESS="./fastchess"

chmod +x "$ENGINE_A" "$ENGINE_B" "$FASTCHESS"

echo "=== [$(date)] Starting fastchess tournament ==="
echo "Games: $GAMES, TC: $TC, Threads/engine: $THREADS_PER_ENGINE, Concurrency: $CONCURRENCY, Hash: ${HASH_MB}MB"

MCHESS_INIT=$(cat <<EOT
uci
setoption name Threads value $THREADS_PER_ENGINE
setoption name Hash value $HASH_MB
isready
EOT
)

"$FASTCHESS" \
  -engine cmd="$ENGINE_A uci" name="MChess-A" init="$MCHESS_INIT" \
  -engine cmd="$ENGINE_B uci" name="MChess-B" init="$MCHESS_INIT" \
  -games "$GAMES" \
  -concurrency "$CONCURRENCY" \
  -pgnout "$RESULT_DIR/match.pgn" \
  -logdir "$LOG_DIR" \
  > "$RESULT_DIR/tournament.log" 2>&1

echo "=== [$(date)] Tournament completed ==="
echo "Results in: $RESULT_DIR"
