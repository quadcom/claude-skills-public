# FeedLog endpoints

Every path below is relative to the board's address. `<id>` is a UUID; `<slug>` is the
hyphenated form in a card's public URL. Routes under `/api/admin/` need a *manager* or *owner*
token; the three deletes additionally need the delete capability an owner grants per token.

## Who am I

| Call | Notes |
|---|---|
| `--check` | Prints the account, email and role. Use this rather than calling the session endpoint directly — its raw response contains the token. |

## Reading

| Call | Notes |
|---|---|
| `GET /api/boards` | The boards cards can be filed on, with their ids. |
| `GET /api/roadmap` `boardId=` | The roadmap as visitors see it, grouped into planned / in progress / done. `boardId` optional. |
| `GET /api/posts` `status=` `boardId=` `sort=` `order=` `pageSize=` | Cards, in `.data`. `status` is one of `open`, `planned`, `in_progress`, `done`. `sort` is `createdAt` or `voteCount`; pair with `order=desc`. `pageSize` up to 100. |
| `GET /api/admin/posts/search` `q=` | Full-text search over titles and bodies, in `.data`. Returns a fixed maximum and ignores any page size, so trim the list yourself. |
| `GET /api/posts/<slug>` | One card in full. **Slug, not id.** |
| `GET /api/posts/<id>/comments` | The comment thread. **Id, not slug** — take it from the card payload. |
| `GET /api/admin/changelogs` | Changelog entries, drafts included. |

A card carries `id`, `slug`, `title`, `status`, `voteCount`, `commentCount`, `boardId`, `author`
and `createdAt`. Its public address is `<board>/p/<slug>`.

## Writing

| Call | Body | Notes |
|---|---|---|
| `POST /api/posts` | `{"title","content","boardId"}` | Files a card. `boardId` optional; omitted means the default board. Title up to 200 characters, content up to 10000. Markdown is supported. |
| `PATCH /api/admin/posts/<id>` | `{"title","content","boardId"}` | Edits a card. Send only the fields that change. |
| `PATCH /api/admin/posts/<id>` | `{"status":"planned"}` | Moves a card on the roadmap. There is no manual ordering — each column sorts by votes and date. |
| `POST /api/posts/<id>/comments` | `{"content","parentId","notifyVoters"}` | Comments. `parentId` replies to a comment instead of the card. `notifyVoters` also notifies everyone who upvoted; omit it to let the board decide. Up to 5000 characters. |
| `POST /api/posts/<id>/vote` | `{}` | Adds this account's upvote. |
| `DELETE /api/posts/<id>/vote` | — | Withdraws it. |
| `POST /api/admin/posts/merge` | `{"canonicalPostId","mergedPostId"}` | Folds the second card into the first, carrying votes across. One duplicate per call. |

## Changelog

| Call | Body | Notes |
|---|---|---|
| `POST /api/admin/changelogs` | `{"title","content","categories"}` | Creates a **draft** — nobody sees it until it is published. Title up to 70 characters. `categories` is any of `new`, `improved`, `fixed`; send `[]` for none. |
| `POST /api/admin/changelogs/<id>/publish` | `{}` | Makes the draft visible. Ask first. |

## Deleting

Permanent, and each needs the delete capability. Prefer merging duplicates and moving finished
cards to *done*.

| Call | Notes |
|---|---|
| `DELETE /api/admin/posts/<id>` | Deletes a card and its comments. **Id, not slug.** |
| `DELETE /api/admin/changelogs/<id>` | Deletes an entry, draft or published. |
| `DELETE /api/comments/<id>` | Deletes a comment. |
