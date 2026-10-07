#!/usr/bin/env bash
# Refresh the Google Scholar citation counts on the homepage.
#
#   scripts/update-citations.sh            fetch, commit, push (verbose)
#   scripts/update-citations.sh --dry-run  fetch only; leave commit/push to you
#   scripts/update-citations.sh --auto     for the shell-startup hook: silent
#                                          no-op unless the data is stale, then
#                                          update in the background and send a
#                                          macOS notification
#
# Works from any directory. First run creates a private virtualenv in
# .venv-scholar/ and installs the pinned dependencies (takes ~30s).
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

DRY_RUN=0
AUTO=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --auto) AUTO=1 ;;
    *) echo "usage: $0 [--dry-run] [--auto]" >&2; exit 2 ;;
  esac
done

STALE_DAYS="${SCHOLAR_STALE_DAYS:-14}"
GIT_DIR="$(git rev-parse --git-dir)"
LOG="$GIT_DIR/scholar-update.log"
STAMP="$GIT_DIR/scholar-last-attempt"
LOCK="$GIT_DIR/scholar-update.lock"

notify() {
  [[ $AUTO -eq 1 && "${SCHOLAR_NO_NOTIFY:-0}" != 1 ]] || return 0
  osascript -e "display notification \"$1\" with title \"Scholar citations\"" >/dev/null 2>&1 || true
}

fail() {
  echo "$1" >&2
  notify "$1"
  exit 1
}

mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1"; }
days_since() { # $1 = YYYY-MM-DD
  local then
  then=$(date -j -f %Y-%m-%d "$1" +%s 2>/dev/null || date -d "$1" +%s)
  echo $(( ($(date +%s) - then) / 86400 ))
}

if [[ $AUTO -eq 1 ]]; then
  # Only act when it's safe and due; otherwise vanish without a trace.
  [[ "$(git branch --show-current)" == "main" ]] || exit 0
  for f in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply; do
    [[ ! -e "$GIT_DIR/$f" ]] || exit 0
  done

  updated="$(sed -n "s/^updated: *'\{0,1\}\([0-9-]\{10\}\).*/\1/p" _data/scholar.yml | head -1)"
  if [[ -n "$updated" ]] && (( $(days_since "$updated") < STALE_DAYS )); then
    exit 0
  fi

  # At most one attempt per ~20h, so a failing day doesn't retry in every new tab.
  if [[ -f "$STAMP" ]] && (( $(date +%s) - $(mtime "$STAMP") < 72000 )); then
    exit 0
  fi

  mkdir "$LOCK" 2>/dev/null || exit 0 # another terminal is already on it
  trap 'rmdir "$LOCK"' EXIT
  touch "$STAMP"
  exec >>"$LOG" 2>&1
  echo "=== $(date) auto update (data last refreshed ${updated:-never}) ==="
fi

if [[ ! -x .venv-scholar/bin/python ]]; then
  echo "Setting up Python environment (first run only)..."
  python3 -m venv .venv-scholar
fi
.venv-scholar/bin/pip install --quiet --disable-pip-version-check -r scripts/requirements.txt

echo "Fetching citation counts from Google Scholar..."
if ! .venv-scholar/bin/python scripts/update_scholar.py; then
  if [[ $AUTO -eq 1 ]]; then
    fail "Google Scholar didn't answer; will try again tomorrow."
  fi
  echo
  echo "Google Scholar didn't answer. It rate-limits now and then: wait a bit"
  echo "and retry, or switch network (e.g. a phone hotspot) and try again."
  echo "Nothing was changed."
  exit 1
fi

if git diff --quiet -- _data/scholar.yml; then
  echo "Citation data is already up to date. Nothing to commit."
  exit 0
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run: _data/scholar.yml updated, not committed."
  git --no-pager diff --stat -- _data/scholar.yml
  exit 0
fi

# Path-limited commit: any other work in progress stays untouched.
git add _data/scholar.yml
git commit -q -m "Update Google Scholar citation counts" -- _data/scholar.yml
git push -q || fail "Citations committed locally, but 'git push' failed. Push manually."

total="$(sed -n 's/^citations: *\([0-9]*\).*/\1/p' _data/scholar.yml | head -1)"
echo "Done. The site will pick up the new numbers in a minute or two."
notify "Homepage updated: ${total} citations."
