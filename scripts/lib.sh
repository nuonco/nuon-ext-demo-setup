#!/usr/bin/env bash

NUON_BIN="${NUON_BIN:-nuon}"
DEMO_STATE_DIR="${DEMO_STATE_DIR:-$HOME/.nuon-demo}"

log() {
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$LOG_FILE" >&2
}

die() {
  log "ERROR: $*"
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"
}

nuon_data() {
  local out
  if ! out=$("$NUON_BIN" --output agent "$@" 2>>"$LOG_FILE"); then
    die "nuon $* -> $(jq -r '.error.description // .error.message // .error // .' <<<"$out" 2>/dev/null || printf '%s' "$out")"
  fi
  jq -e -c '.data' <<<"$out" || die "nuon $* returned an invalid agent response"
}

api_get() {
  curl -sS -f \
    -H "Authorization: Bearer $NUON_API_TOKEN" \
    -H "X-Nuon-Org-ID: $NUON_ORG_ID" \
    "${NUON_API_URL%/}$1"
}
