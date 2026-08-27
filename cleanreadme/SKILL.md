---
name: cleanreadme
description: Remove the development-branch warning banner from README.md on the published branch, normally straight after a merge from the development branch lands. Use when the user says "cleanreadme", or when the published branch's README is showing the development warning.
---

# cleanreadme

`dev` carries a "development branch — do not install from here" banner in its README as ordinary
committed content. `main` must never show it. Work merges one way, `dev` → `main`, so the one moment
the banner is wrong is immediately after that merge lands. This skill removes it.

**The mirror of this skill is `devbanner`**, which puts the same block back on `dev`.

## Branch names

Written for the common pair: work happens on **`dev`** and is published from **`main`**. If a
project uses `develop`/`master`, or anything else, substitute throughout — the names are not
load-bearing, the direction is. Read the project's actual branches before assuming; `git branch -a`
is the check.

## The invariant this rests on

**`main`'s README has no content of its own. It is only ever `dev`'s README minus the banner.**

That is what makes the conflict resolution below safe: replacing main's copy with dev's wholesale
cannot lose anything, because there was never anything unique there to lose.

**So the README is never edited directly on `main`.** Readme changes are made on `dev` and arrive by
merge like everything else. If you find yourself about to fix a typo on `main`, fix it on `dev`
instead. An edit made only on `main` breaks the invariant silently, and the next conflict resolution
will quietly throw it away.

## What to expect: usually there is nothing to do

Git remembers that `main` deliberately deleted the banner block. On later merges `dev` has not
touched those lines since, so the deletion wins and the banner does not come back. **Proved in a
scratch repository**, not assumed.

So this skill has real work only twice: the first time, and after a `devbanner` wording change. Every
other run is a confirmation that nothing slipped through, and finding nothing is a pass, not a
failure. **Report "already clean" plainly rather than manufacturing a change.**

## How it comes back — measured, not reasoned

**It can never come back silently.** Every case that would reintroduce it stops the merge with a
conflict instead. Tested 2026-08-22 across seven cases in a scratch repository:

| What `dev` does to README.md | Result |
|---|---|
| Edits the line **immediately** below the banner | **conflict** |
| Edits anything two lines below it or further down | clean, banner stays out |
| Inserts a new line **above** the banner | **conflict** |
| Changes the banner's own wording (a `devbanner` run) | **conflict** |
| Rewrites the whole file | **conflict** |

So the danger is not git — it is **how the conflict gets resolved**. The sensible resolution takes
dev's copy of the file whole, and that carries the banner across with it.

**Resolution, when README.md is the conflicted file:** take dev's version wholesale —
`git checkout dev -- README.md` — then run this skill's removal on the result and commit. Never
hand-resolve the conflict markers. Dev's copy is the correct content in full; the only thing wrong
with it is the banner, which is precisely what this removes.

**A README conflict during a merge is the signal to run this skill.** If anything **other** than
README.md conflicts, that is a code conflict and none of this skill's business — stop and hand it
back.

## Step 1 — check the ground

```sh
git fetch origin
git worktree list
git status --short
git branch --show-current
```

**Hard gate, before touching anything.** Run `git branch --show-current` and read the answer.

- **If it does not say `main`, do not edit a single file in this folder.** Not "probably fine", not
  "the user obviously meant main". Stop, and either add a throwaway worktree on `main`
  (`git worktree add <scratch>/cleanreadme main`) and work there, or say why you cannot and stop.
  **Never switch this folder's branch** — somebody else may be working in it, and the one failure
  this skill can cause that cannot be undone from the other branch is stripping the banner off
  `dev`. Everything else it might get wrong is recoverable; that one is the whole point of the
  gate.
- **Confirm the same thing again inside the worktree** if you made one. A worktree that failed to
  create leaves you standing in the original folder, and the next command would then edit `dev`.
- **A dirty tree stops the run**, unless the only dirty entry is a README.md conflict from the merge
  this was called to finish. Do not stash and do not commit on anybody's behalf.

## Step 2 — remove the block

Delete everything from the opening `dev-banner` marker to its closing partner inclusive, plus the
single blank line following it. **Everything else in the file stays exactly as it is.**

**Markers may carry a project prefix.** `devbanner` writes the bare form into a README that has
none, but preserves a prefixed form such as `<!-- myproject:dev-banner -->` where a project already
uses one. Match both, and note that opening and closing need separate patterns — the closing marker
carries a `/`:

```
opening:  <!--\s*[A-Za-z0-9_-]*:?dev-banner\s*-->
closing:  <!--\s*/[A-Za-z0-9_-]*:?dev-banner\s*-->
```

The opening pattern deliberately does not match the closing marker, so counting them separately is
meaningful.

**Position is irrelevant.** The banner normally sits under the title, but a conflict resolution can
leave it anywhere. Find it by its markers and remove it where it is. Never remove "the block near the
top", never work from a line number, and never assume the file has any particular shape — the readme
is edited constantly on `dev` and its shape is not this skill's business.

**Match on the markers, never on the wording, and never on line numbers.** The wording is allowed to
change and the file's shape is allowed to change; the two marker lines are the only contract. They
appear nowhere else in the README, so the match is exact.

- If the markers are absent, **there is nothing to do** — say so and stop.
- Do **not** go hunting for the banner text as a fallback. A near-miss match would cut something
  real out of the README, and that is a worse outcome than leaving a banner up for an hour.
- Match the opening marker to the **nearest** closing marker, not the last one in the file. If a
  closing marker is missing entirely, **remove nothing** and report it — an unterminated match would
  swallow the rest of the file.
- If there is more than one pair, remove them all, and say so: two banners means an earlier run
  appended instead of replacing, which is a bug worth naming rather than quietly tidying.

## Step 3 — prove it before committing

- **`main` contains neither marker.** Count both; both answers must be 0.
- No fragment of the banner wording survives — check for the warning's own phrasing as well as the
  markers, since a partial removal would pass a marker count while leaving text on screen.
- Diff against the previous commit: the removed lines should be **exactly** the banner block and its
  trailing blank line, with **nothing added** and nothing else removed. Anything else means the
  removal overreached.
- `dev` still has its banner. This is the check that matters most, because the failure it catches is
  invisible on `main` and permanent on `dev`. Confirm the markers are still present on `dev`, and if
  they are not, **stop and say so before pushing anything**.

## Step 4 — pushing

**Pushing `main` is publishing — ask first**, and say what is about to become the project's front
page. Remove any throwaway worktree afterwards (`git worktree remove <path>`).
