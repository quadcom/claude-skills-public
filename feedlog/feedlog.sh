#!/usr/bin/env bash
#
# A dependency-free HTTP front-end for a self-hosted FeedLog board.
#
# Every call goes through the board's own endpoints rather than its database,
# deliberately: the endpoints are what keep vote tallies, duplicate-detection
# embeddings, subscriptions, notifications and the activity trail correct. A
# direct database write would leave the board quietly inconsistent with itself.
#
#   feedlog.sh --check
#   feedlog.sh GET   /api/boards
#   feedlog.sh GET   /api/posts status=planned sort=voteCount pageSize=10
#   feedlog.sh POST  /api/posts '{"title":"...","content":"..."}'
#   feedlog.sh PATCH /api/admin/posts/<id> '{"status":"in_progress"}'
#
# key=value arguments become query parameters; a single {...} argument is the
# JSON body. Output is the response body, or a diagnosis on failure.

set -euo pipefail

die() { echo "$*" >&2; exit 1; }

# First readable file wins, so an explicit setting beats the project's own file.
# Trailing newlines are stripped — a credential pasted into an editor almost
# always has one.
read_first() {
  local f
  for f in "$@"; do
    [ -n "$f" ] && [ -r "$f" ] && { tr -d '\r\n' < "$f"; return 0; }
  done
  return 1
}

BASE="${FEEDLOG_URL:-$(read_first "${FEEDLOG_URL_FILE:-}" local/feedlog-url.txt || true)}"
TOKEN="${FEEDLOG_TOKEN:-$(read_first "${FEEDLOG_TOKEN_FILE:-}" local/agent-token.txt || true)}"
BASE="${BASE%/}"

[ -n "$BASE" ]  || die "No board address. Set FEEDLOG_URL, or save the board's address to local/feedlog-url.txt (run from the project root)"
[ -n "$TOKEN" ] || die "No agent token. Set FEEDLOG_TOKEN, or save the token to local/agent-token.txt (run from the project root)"

if [ "${1:-}" = "--check" ]; then
  set -- GET /api/auth/get-session
  CHECK=1
fi

[ $# -ge 2 ] || die "Usage: feedlog.sh METHOD PATH [key=value ...] ['{json body}']"

METHOD=$1
PATH_=$2
shift 2

# The token travels in a header and never in the address. FeedLog writes every
# request's path AND query string to its container log, so a token in a query
# parameter would sit in clear text on the server.
ARGS=(-sS -X "$METHOD"
      -H "Authorization: Bearer $TOKEN"
      -H 'Content-Type: application/json'
      -H 'Accept: application/json'
      -w '\n%{http_code}')

USE_GET=
for a in "$@"; do
  case "$a" in
    '{'*|'['*) ARGS+=(--data-binary "$a") ;;
    *=*)       ARGS+=(--data-urlencode "$a"); USE_GET=1 ;;
    *)         die "Unrecognised argument: $a (expected key=value or a JSON body)" ;;
  esac
done
# --get moves the encoded pairs into the query string instead of the body, and
# curl does the escaping, which matters for search terms with spaces.
[ -n "$USE_GET" ] && ARGS+=(--get)

OUT=$(curl "${ARGS[@]}" "$BASE$PATH_")
CODE=${OUT##*$'\n'}
BODY=${OUT%$'\n'*}

case "$CODE" in
  2*) ;;
  401) die "The agent token was rejected. It may have been revoked or expired — mint a new one in the dashboard under Developer -> Agent tokens." ;;
  403) die "Refused (403): ${BODY}. This needs a higher role than the token has, or a capability an owner grants per token." ;;
  404) die "Not found (404): $PATH_. Reading a card uses its slug; every other route uses its id." ;;
  *)   die "Failed ($CODE): ${BODY}" ;;
esac

# The session payload embeds the token itself, so --check must never print it
# raw. Pull out only the three facts worth knowing and discard the rest.
if [ -n "${CHECK:-}" ]; then
  name=$(printf '%s' "$BODY"  | grep -o '"name":"[^"]*"'  | head -1 | cut -d'"' -f4)
  email=$(printf '%s' "$BODY" | grep -o '"email":"[^"]*"' | head -1 | cut -d'"' -f4)
  role=$(printf '%s' "$BODY"  | grep -o '"role":"[^"]*"'  | tail -1 | cut -d'"' -f4)
  [ -n "$name" ] || die "Connected, but the token did not resolve to a user. It has probably been revoked."
  echo "OK - $BASE"
  echo "Authenticated as: $name ($email)"
  echo "Role: ${role:-unknown}"
  case "$role" in
    manager|owner) echo "Can moderate cards and publish changelog entries." ;;
    *)             echo "Read, post, vote and comment only - cannot moderate." ;;
  esac
  exit 0
fi

printf '%s\n' "$BODY"
