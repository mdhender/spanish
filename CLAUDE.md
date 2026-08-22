# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Hugo static site of Spanish lessons, deployed to <https://spanish.mdhenderson.com>. There
is no application code, no test suite, and no linter — the build is the check. "Working"
means `hugo --gc --minify` completes with **no WARN or ERROR lines** and the expected pages
appear under `public/`.

Deployment is `scripts/deploy.sh` — it builds and rsyncs `public/` to the web root over
SSH, run by hand. **This project does not use CI**: do not add GitHub Actions workflows, a
`.github/` directory, a `CNAME`, or any other CI or hosting config — their absence is a
decision, not an oversight.

The script builds with `--cleanDestinationDir` for a reason. `hugo` alone leaves output for
pages that no longer exist, and `rsync --delete` only removes files *missing locally*, so a
stale page would be uploaded rather than deleted and its old URL would stay live. Keep that
flag.

## Git

Commit directly to `main`. **Do not create branches** for changes in this repo, and do not
open pull requests — this is a single-author site and the branch-per-change workflow is
explicitly not wanted here.

## Commands

```sh
hugo server                    # dev server at localhost:1313, live reload
hugo --gc --minify             # production build into public/
hugo mod get -u                # update Hextra to its latest release
hugo mod tidy                  # after changing module imports
hugo new content tutorials/greetings.md
```

Requires Hugo **extended** (built with v0.163.1) and Go — Go is not optional here, see below.

There is no single-test command. To check one section in isolation, build to a scratch
directory and inspect the output rather than adding config:

```sh
hugo --quiet --destination /tmp/probe && ls /tmp/probe/tutorials/
```

## Architecture

### The theme is a Hugo Module, not a directory

Hextra v0.12.3 is pulled in via `module.imports` in `hugo.yaml`. There is deliberately **no
`theme:` key and no `themes/` directory** — adding either will conflict with the module.
This is why Go is required: `go.mod`/`go.sum` pin the theme, and a fresh checkout needs
`hugo mod get` before it will build.

The theme source is read-only in the Go module cache. To inspect what a layout or shortcode
actually does:

```sh
ls "$(go env GOMODCACHE)/github.com/imfing/hextra@v0.12.3/layouts/"
```

`layouts/`, `assets/`, and `data/` are empty locally (`i18n/en.yaml` holds one string, see below). To override a theme file,
create the matching path under `layouts/` — Hextra 0.12.3 uses Hugo's newer
`layouts/_partials/` and `layouts/_shortcodes/` convention, not the legacy `partials/` and
`shortcodes/`. Getting that prefix wrong fails silently: the override is ignored and the
theme's version renders.

### Sections are configured once, pages inherit

Each of the four section `_index.md` files carries `cascade: type: docs`. That cascade is
what produces the docs layout and sidebar, so **new pages need only `title` and `weight`** in
front matter — do not add `type: docs` per page. `weight` orders pages within a section.

The site root (`content/_index.md`) is the exception: it sets `layout: hextra-home` and is
built from Hextra's hero and feature-card shortcodes, so it does not follow the docs layout
at all.

### Content is organized by Diataxis, and that is the point

Four top-level sections, each serving a different reader need. The names are the canonical
Diataxis ones — singular `reference` and `explanation` are intentional, do not "fix" them to
plurals:

| Path                   | Reader is...                              |
| ---------------------- | ----------------------------------------- |
| `content/tutorials`    | learning by doing — guided lessons         |
| `content/how-to`       | reaching a goal they already have in mind  |
| `content/reference`    | looking a fact up mid-task                 |
| `content/explanation`  | building understanding, away from the task |

The separation is a real constraint, not a filing convention. A tutorial that stops to
explain grammar, or a reference page that argues for an approach, belongs in two documents
that link to each other. Each section's `_index.md` states what belongs in it — read the
target section's index before adding a page to it. The `diataxis` skill has the full
framework if a page is hard to classify.

### Config decisions that look like omissions

These are in `hugo.yaml` and each was deliberate; changing one without knowing why will
break something:

- `disableKinds: [taxonomy, term]` — no blog exists, so tag/category pages were empty. Re-enable
  when adding a blog.
- `enableRobotsTXT: false` — `static/robots.txt` is the source of truth (it carries the sitemap
  URL). Turning the generated one back on makes two files compete.
- `footer.displayPoweredBy: false` — the Hugo and Hextra credits live on `/about/`
  (`content/about.md`) instead of in the footer. Keep them there.
- `markup.goldmark.renderer.unsafe: true` — required, Hextra's shortcodes emit raw HTML.
- `locale: en-US`, not `languageCode` — the latter is deprecated as of Hugo v0.158 and warns.

### Licensing and the footer notice

Content is **CC BY-SA 4.0**. `LICENSE` is the license text fetched verbatim from
creativecommons.org — do not reformat, re-wrap, or hand-edit it.

`content/about.md` is the only page outside the four Diataxis sections; it is site meta,
not lesson content, and gets no `type: docs` cascade, so it renders in Hextra's centered
page layout without a sidebar.

The footer notice is not a layout override. Hextra's footer renders `{{ T "copyright" }}`
through `markdownify`, so `i18n/en.yaml` sets that one string and the attribution appears
site-wide. Editing the footer text means editing that file, not a partial. The year in it
is static and needs a manual bump.

`baseURL` is the production URL, so absolute links in built output point at
spanish.mdhenderson.com even in local builds. Use root-relative paths (`/reference/`) in
content links.
