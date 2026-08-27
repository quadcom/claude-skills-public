---
name: readme-writer
description: Write or rewrite a project's README.md so it reads like a landing page rather than an instruction manual - what the project is for, who it helps, and how to run it in a minute. Use when the user asks for a README, says the README is bad or out of date, or a new project has none.
---

# readme-writer

A README is a front page, not a manual. Someone lands on it having never heard of the project and
gives it about fifteen seconds. In that time they decide whether it solves a problem they actually
have. Everything else in the file is for the people who survive that fifteen seconds.

Write for the reader who is **not yet convinced**. Reference material is for the reader who already
is, and belongs lower down or in `docs/`.

## Read the project before writing a word

The single worst failure here is a confident README describing a project that does not exist. It is
also the easiest to commit, because a plausible README can be written from the repository name
alone. Do not.

Read, in roughly this order, and stop when the picture is clear:

- The **package manifest** — `package.json`, `pyproject.toml`, `Cargo.toml`, `composer.json`. Name,
  description, scripts, entry points, dependencies, licence, minimum runtime version.
- The **entry point** and whatever it immediately calls. What does this thing actually do on start?
- **Configuration** — `.env.example`, `config/`, a settings module. Every required variable is
  something the reader must be told about, and every default is something they need not be.
- **Existing docs**, including an old README. Salvage what is true; the previous author usually knew
  something you do not.
- **Tests**, if the purpose is still unclear. Tests describe intended behaviour more honestly than
  prose does.

If something remains genuinely ambiguous after that — who it is for, what problem it solves, whether
a feature is finished — **ask rather than guess**. A wrong guess in a README is repeated by everyone
who quotes it.

## Structure

Adapt, do not follow mechanically. A library and a self-hosted application need different pages.

1. **Title, then one sentence.** What it is, for whom, in a line a stranger understands. No tagline
   poetry, no "A modern, blazing-fast…".
2. **Why this exists.** The pain, in the reader's terms. Name the status quo and what is wrong with
   it. Two or three sentences; this is the part that decides whether they keep reading.
3. **What it does.** Three to five bullets, ordered by how much a reader would care. Each starts
   with the outcome.
4. **A 60-second start.** The shortest honest path from nothing to a working thing. Copy-pasteable,
   in order, no prose between the commands that is not needed to run them.
5. **Screenshot or example**, if the project has a face. One good image beats a paragraph. For a
   library, a short realistic code sample does the same job.
6. **Configuration**, further down, dense and complete. This is where the tables live.
7. **Limitations or requirements**, honestly. What it does not do, what it needs, what it is not
   suitable for.
8. **Licence**, one line.

The order matters more than the headings. Impressive and lifestyle-changing at the top; technical
and exhaustive at the bottom. If a section makes the reader work before they are convinced, it is
too high up.

## Rules that decide how it reads

**Lead with the outcome, not the mechanism.** Every feature bullet starts with what the reader gets.

> Paste a Compose file, get a form you can actually fill in.

not

> Parses YAML into an intermediate representation and renders it as HTML inputs.

**No under-the-hood detail above the fold.** *How* it works is interesting to you and irrelevant to
someone deciding whether to try it. Architecture belongs in `docs/`, or in a "How it works" section
near the bottom for the curious.

**Write like a senior developer talking to a peer** — plainly, without selling. Assume competence,
assume scepticism, assume they have been disappointed by three similar projects this month.

**Avoid the words that make writing read as machine-generated.** They are empty in every context
they appear in:

> revolutionary · seamless · seamlessly · powerful · power · robust · testament · delve ·
> leverage · unleash · elevate · game-changing · cutting-edge · state-of-the-art · effortless ·
> supercharge · streamline · comprehensive · rich set of · plethora · myriad · dive in · unlock

The test is not the word list, it is the sentence: **if deleting the adjective loses no information,
it was decoration.** "A robust caching layer" and "a caching layer" say the same thing.

**One idea per sentence.** Long sentences with three clauses are where vagueness hides.

**Numbers beat adjectives.** "Starts in under a second" is worth more than "fast". Only use a number
you have actually seen.

## What to leave out

- **Badge walls.** One or two that earn their place — build status, licence. Not nine.
- **A table of contents** for a page shorter than a screen or three. It is scroll noise.
- **A roadmap.** It rots faster than any other section and reads as a promise. Issues do this job.
- **Emoji as section headings.** Fine sparingly inside text; as decoration on every heading they
  make the page harder to scan, not easier.
- **Feature lists that restate the API.** A list of every function is reference material.
- **"Contributing" in full.** A line pointing at `CONTRIBUTING.md` is enough on the front page.
- **Anything aspirational stated in the present tense.** If it is not built, it does not go in.

## Prove it before handing it over

A README's failure mode is being wrong, not being ugly. Check, do not assume:

- **Every command runs as written**, in the order given, from a clean clone. Wrong install commands
  are the most common README bug and the most damaging — the reader's first act fails.
- **Every version, port and path matches** the manifest and the config files, rather than a
  convention you expect.
- **Every feature claimed exists.** Point at the code for each bullet. Delete anything you cannot.
- **The licence matches** the `LICENSE` file. Do not infer one.
- **No internal detail leaked** — hostnames, IP addresses, internal URLs, real credentials, private
  repository links, a colleague's name. This applies to example commands, which is where such things
  survive a rewrite.
- **The first screen stands alone.** Read only down to where the fold would be. Would a stranger know
  what this is and whether it is for them? If not, the top is wrong regardless of how good the rest
  is.

## When rewriting rather than starting fresh

Keep what is true and specific; the previous author knew the project. Rewrite what is vague. Delete
what is stale — an out-of-date instruction is worse than a missing one, because it is trusted.

Say what changed and why when handing it back, and flag anything that looked wrong but that you left
alone because you could not confirm it. **A README is the project's front page: treat replacing it as
publishing, and show the draft before committing.**
