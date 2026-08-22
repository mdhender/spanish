# Spanish Lessons

Hugo site for <https://spanish.mdhenderson.com>, built with the
[Hextra](https://imfing.github.io/hextra/) theme.

## Requirements

- Hugo **extended** (built with v0.163.1)
- Go (Hextra is installed as a Hugo Module)

## Local development

```sh
hugo mod get -u        # first checkout, or to update the theme
hugo server            # http://localhost:1313
```

Build the production site into `public/`:

```sh
hugo --gc --minify
```

## Content structure

Content follows [Diataxis](https://diataxis.fr/), which splits documentation by what the
reader is doing:

| Folder                | Type        | Serves                                          |
| --------------------- | ----------- | ----------------------------------------------- |
| `content/tutorials`   | Tutorial    | Learning by doing — guided lessons               |
| `content/how-to`      | How-to      | Reaching a specific goal — you know what you want |
| `content/reference`   | Reference   | Looking things up — tables, charts, facts          |
| `content/explanation` | Explanation | Understanding — why the language works this way    |

Keep the types separate. If a page is teaching and explaining at once, split it and link
the two halves.

### Adding a page

```sh
hugo new content tutorials/greetings.md
```

Each section cascades `type: docs`, so new pages pick up the docs layout and sidebar
automatically. Order pages within a section with `weight` in the front matter.

## License

Copyright © 2026 Michael Henderson.

The lesson content in this repository is licensed under the
[Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa] — you may
share and adapt it, including commercially, provided you give credit and license your
derivative under the same terms. Full text in [`LICENSE`](LICENSE).

The Hextra theme is a separate work with its own license; it is fetched as a Hugo Module
and is not distributed in this repository.

[cc-by-sa]: https://creativecommons.org/licenses/by-sa/4.0/
