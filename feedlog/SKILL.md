---
name: feedlog
description: Work a self-hosted FeedLog feedback board over plain HTTP using an agent token - list, search and read cards, file new ones, edit them, vote, comment, move them along the roadmap, merge duplicates, and draft then publish changelog entries. Use whenever the user mentions the feedback board, a card or feature request, the roadmap, or the changelog.
---

# FeedLog

Talk to a self-hosted [FeedLog](https://github.com/linkcraftstudio/feedlog) board as a real
account, using a long-lived agent token.

Everything goes through the board's own HTTP endpoints rather than its database, deliberately: the
endpoints are what keep vote tallies, duplicate-detection embeddings, subscriptions, notifications
and the activity trail correct. A direct database write leaves the board quietly inconsistent with
itself.

## Setup

Needed once **per project**. FeedLog covers one project per board, so each project keeps its own
token and its own board address, and the skill picks the right one from wherever it is run.

1. **Mint a token.** In the board's dashboard, go to **Developer -> Agent tokens** (owner only) and
   press **Create token**. Leave the role on *Manager* to moderate cards and publish changelog
   entries; choose *Contributor* for read, post, vote and comment only. Deleting anything needs a
   capability granted per token, separately from the role. The token is shown once.

2. **Save the token and the board address** in the project's own gitignored folder:

   ```
   local/agent-token.txt     the token, on its own, nothing else
   local/feedlog-url.txt     e.g. https://feedback.example.com
   ```

   Check that `local/` is in the project's `.gitignore` before saving anything into it. The
   environment variables `FEEDLOG_TOKEN`, `FEEDLOG_URL`, `FEEDLOG_TOKEN_FILE` and `FEEDLOG_URL_FILE`
   override the files where that is useful.

3. **Check it**, which reports the account and what its role may do:

   ```bash
   bash ~/.claude/skills/feedlog/feedlog.sh --check
   ```

## Making calls

One script does every request. It finds the token and address, sets the auth header, encodes query
parameters, and turns failures into an explanation:

```bash
FL=~/.claude/skills/feedlog/feedlog.sh

bash $FL GET    /api/boards
bash $FL GET    /api/posts status=planned sort=voteCount pageSize=10
bash $FL POST   /api/posts '{"title":"Dark mode","content":"Please."}'
bash $FL PATCH  /api/admin/posts/<id> '{"status":"in_progress"}'
bash $FL DELETE /api/posts/<id>/vote
```

`key=value` arguments become query parameters; a single `{...}` argument is the JSON body. Pipe
through `jq` if it is available; otherwise read the JSON as it comes.

**Always run from the project root.** The script looks for `local/feedlog-url.txt` and
`local/agent-token.txt` relative to the current directory, so the directory you are standing in is
what decides which board you talk to. Run it from a subfolder and it reports no board configured;
that is the guard working, not a fault. It never falls back to another project's board.

`reference.md` in this folder lists every endpoint with its parameters. Read it before composing a
call you have not made before.

## Rules that matter

- **Never put the token in a URL.** FeedLog logs every request's path *and* query string, so a
  token in a query parameter ends up in clear text in the server's log. The script always sends it
  as a header; keep it that way.
- **Never print the session endpoint's raw response.** `GET /api/auth/get-session` includes the
  token in its payload. Use `--check`, which prints only the account and role.
- **Reading a card uses its slug; everything else uses its id.** This is an upstream inconsistency,
  not a mistake in the skill: `GET /api/posts/:x` matches on slug, every other route matches on id.
  Listing and search return both fields, so carry the right one.
- **Search before filing.** The board detects likely duplicates, but not filing one is better.
- **Prefer merging to deleting.** Fold duplicates into the card that should survive so its votes
  carry across; move finished work to *done* rather than removing it. Deletion is permanent, and
  should be a last resort.
- **Ask before deleting anything**, and before publishing a changelog entry — publishing is what
  makes it visible to everyone, and it cannot be quietly undone.

## When something is refused

- **401** — the token was rejected. It has been revoked or has expired; mint another.
- **403** — the token's role is too low, or the action needs the delete capability an owner grants
  per token. Run `--check` to see which role you actually have.
- **404 on a card** — you almost certainly passed an id where a slug was wanted, or the reverse.
