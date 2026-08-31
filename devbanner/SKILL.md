---
name: devbanner
description: Put a "development branch — the bleeding edge, not the stable release" warning banner into README.md on the development branch, or bring its wording up to date. Use when the user says "devbanner", or when the development branch's README has lost the banner or shows an old version of it.
---

# devbanner

The banner is ordinary committed content on the development branch. It is not stamped on every
merge and nothing regenerates it — it simply lives in that branch's README. This skill exists for
the two occasions when that is not true: it went missing, or the wording in `banner.md` changed.

**The mirror of this skill is `cleanreadme`**, which removes the same block from the published
branch. Between them there is exactly one copy of the wording, in `banner.md`, and neither skill
ever retypes it. If you do not have `cleanreadme`, the removal is a hand edit — find the markers,
delete the block between them, done.

## Branch names

Written for the common pair: work happens on **`dev`** and is published from **`main`**. If a
project uses `develop`/`master`, or anything else, substitute throughout — the names are not
load-bearing, the direction is. Read the project's actual branches before assuming; `git branch -a`
is the check.

## The flow this assumes

Work happens on the development branch and merges **one way** into the published branch. The banner
is present throughout and is removed at the final gate by `cleanreadme`.

**Merges must never run published → development.** The published branch carries a deliberate
deletion of the banner block; merged backwards, that deletion travels into the development branch
and silently removes the banner there. Proved in a scratch repository, not assumed.

## Step 1 — check the ground

```sh
git fetch origin
git worktree list
git status --short
git branch --show-current
```

**Hard gate, before touching anything.** Run `git branch --show-current` and read the answer.

- **If it is not the development branch, do not edit a single file in this folder.** Stop, and
  either add a throwaway worktree on it (`git worktree add <scratch>/devbanner dev`) and work there,
  or say why you cannot and stop. **Never switch this folder's branch.** The failure this gate
  prevents is stamping the banner onto the published branch, which puts a "this is the bleeding edge"
  warning on the project's public front page.
- **Confirm the same thing again inside the worktree** if you made one. A worktree that failed to
  create leaves you standing in the original folder.
- **A dirty tree stops the run.** Other agents work in project folders. Do not stash and do not
  commit on their behalf — say so and stop.

## Step 2 — apply the banner

1. Read `banner.md` from this skill's own folder. **That is the only copy of the wording.** Never
   retype it and never improve it in passing.

2. It is wrapped in `<!-- dev-banner -->` / `<!-- /dev-banner -->`. HTML comments do not render on
   GitHub, so the markers are invisible to readers while giving an exact region to find.

   **Match markers loosely, write them back exactly as found.** A project may already use a
   prefixed form such as `<!-- myproject:dev-banner -->`, from an earlier version of this skill or
   a neighbouring convention. Search with a pattern that accepts both, and note that the opening
   and closing markers need separate patterns — the closing one carries a `/`:

   ```
   opening:  <!--\s*[A-Za-z0-9_-]*:?dev-banner\s*-->
   closing:  <!--\s*/[A-Za-z0-9_-]*:?dev-banner\s*-->
   ```

   The opening pattern deliberately does not match the closing marker, so counting them separately
   is meaningful. If the README already has a prefixed pair, **keep that prefix** when writing the
   block back — changing it would strip the markers `cleanreadme` is
   looking for on the other branch, and the banner would then survive into the published branch
   unnoticed. Only a README with no markers at all gets the bare `dev-banner` form.

3. **If the markers are present, replace everything between and including them, where they are.** Do
   not skip, do not append, and **do not relocate the block** — if a merge left it lower in the
   file, the wording gets refreshed in place and its position is left alone. Moving it would show as
   lines removed from one part of the file and added to another, which is indistinguishable from
   losing something. Skipping is wrong the moment the wording changes — "a banner is already there"
   is true and stale at the same time — and appending leaves two.

4. If the markers are absent, insert the block **immediately after the title line and the blank line
   beneath it**, followed by one blank line. The file reads: the `# Project name` heading, blank,
   banner, blank, the rest.

The link to the published branch is **relative** — `../../blob/main/README.md`. GitHub resolves that
against the repository being viewed, so it points at the right project without the banner naming any
repository. Do not replace it with an absolute URL: that would hardcode one project into a file
meant to be shared, and it silently points at the wrong repository in a fork.

The banner is a GitHub alert (`> [!CAUTION]`) with a heading inside it, and that is deliberate.
GitHub strips styling from READMEs, so a literal colour needs either a LaTeX trick or an external
image — and readers choose their own light or dark theme, which makes a hardcoded white invisible
for half of them. An alert colours itself correctly in both, and a real heading is genuinely larger
rather than merely bolder. **Do not "improve" this into inline styling; it will be stripped, and
white text will vanish on a light background.**

## Step 3 — prove it before committing

Do not trust the edit:

- Count the opening marker. The answer must be **exactly 1**, not "at least 1". Count the closing
  marker too — one of each, in that order.
- Diff against the previous commit. Added lines should equal the banner's own line count plus the
  blank line after it, and **nothing should be removed** unless an older banner was replaced, in
  which case the removals must be exactly that old block and nothing else. A removal anywhere else
  means the insert landed wrong and ate something.
- If the wording changed, confirm no fragment of the old wording survives anywhere in the file.
- If the README already used a prefixed marker, confirm the prefix is **unchanged**. This is the
  check that catches the failure that only shows up later, on the other branch.

Commit on the development branch saying what changed. Pushing that branch needs no permission.
Remove any throwaway worktree afterwards.
