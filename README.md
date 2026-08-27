# claude-skills

Claude Code skills that are useful outside the project they were written for.

Each folder is one skill. Install the ones you want by copying the folder into `~/.claude/skills/`:

```sh
git clone https://github.com/quadcom/claude-skills-public.git
cp -r claude-skills-public/feedlog ~/.claude/skills/
```

Claude Code reads `~/.claude/skills/<name>/SKILL.md`. There is no build step and nothing to
register — the folder being there is the whole installation.

## Skills

### `feedlog`

Work a self-hosted [FeedLog](https://github.com/linkcraftstudio/feedlog) feedback board over plain
HTTP, as a real account, using a long-lived agent token: list, search and read cards, file and edit
them, vote, comment, move them along the roadmap, merge duplicates, and draft then publish changelog
entries.

Everything goes through the board's own HTTP endpoints rather than its database, deliberately — the
endpoints are what keep vote tallies, duplicate-detection embeddings, subscriptions, notifications
and the activity trail correct.

**One board per project.** FeedLog covers one project per board, so the skill reads the board
address and token from `local/feedlog-url.txt` and `local/agent-token.txt` **relative to the
directory it is run from**. Install it once at user level and it still talks to the right board in
every project, because the project you are standing in is what selects it. A project with nothing
configured says so rather than falling back to another project's board.

Requires `bash` and `curl`. No other dependencies.

### `devbanner`

Puts a "development branch — do not install from here" warning into `README.md` on a project's
development branch, so nobody installs from work in progress. The banner is ordinary committed
content, not something stamped on every merge — this skill exists for the two moments that is not
enough: it went missing, or its wording changed.

The wording lives in one place, `banner.md`, and the skill never retypes it. The link back to the
published branch is **relative**, so the banner names no repository and works unchanged in any
project, including forks.

Written for the common `dev` → `main` pair; substitute your own branch names, which the skill says
how to do. It reads and preserves an existing marker prefix, so adopting it will not break a project
that already uses a prefixed form such as `<!-- myproject:dev-banner -->`.

Pairs with a `cleanreadme` skill that removes the same block from the published branch. That one is
not published here yet; without it, removal is a hand edit.

## Writing your own

One folder per skill, holding `SKILL.md` with YAML frontmatter:

```markdown
---
name: my-skill
description: What it does, and when Claude should reach for it. This line is how Claude decides
  whether the skill is relevant, so name the trigger, not just the topic.
---

# my-skill

...
```

The `description` is the only part Claude sees before deciding whether to load a skill, so it earns
the effort.

## A note on what belongs here

Skills read as harmless prose and quietly encode infrastructure. Before publishing one, check it for
hostnames and IPs (including in example commands), filesystem paths that reveal how a machine is
arranged, repository URLs that expose a private project, and anything naming a real deployment even
without credentials.

Nothing here reads a credential from the repository. Where a skill needs one, it reads it at run
time from a gitignored file in the project using it.

## Licence

MIT.
