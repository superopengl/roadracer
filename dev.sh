#!/usr/bin/env bash
# Start a local dev server for Roadracer.html.
# The HTML embeds a 1s polling auto-reloader, so saving the file
# triggers a browser refresh automatically — no build step.
set -euo pipefail

PORT="${PORT:-8000}"
URL="http://localhost:${PORT}/Roadracer.html"

cd "$(dirname "$0")"

echo "Serving on ${URL}"
if command -v open >/dev/null 2>&1; then
  (sleep 1 && open "${URL}") &
fi

exec python3 -m http.server "${PORT}"
