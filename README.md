# atlas-brief-single

Brief a single-cell atlas with Claude Code. Give it an atlas's `.h5ad` URL and
its paper, and it writes `projects/<atlas>/brief.md`: the authors' own cell-type
labels, how many cells each, the Cell Ontology term each maps to, and a verbatim
quote from the paper saying what the authors meant.

Everything is in this one repo. The workflow is the skill in
[`.claude/skills/atlas-brief/`](.claude/skills/atlas-brief/SKILL.md), versioned by
this repo's commits and tags. The plugins it uses are pinned to exact releases in
`plugins.toml`:

| Plugin | Version | Does |
|---|---|---|
| `remote-h5ad-obs` | 0.3.0 | reads the per-cell table from a remote h5ad without downloading the matrix |
| `author-annotation-columns` | 0.4.0 | finds the column holding the authors' cell-type labels |
| `paper-access` | 0.3.0 | fetches the paper's full text |
| `onto-mapping` | 0.5.0 | maps each label to a Cell Ontology term |

## First time

1. Install Claude Code: https://docs.claude.com/en/docs/claude-code/setup
2. In a terminal:

   ```sh
   git clone https://github.com/ubyndr/atlas-brief-single.git
   cd atlas-brief-single
   ./setup.sh
   claude
   ```

`setup.sh` installs [uv](https://docs.astral.sh/uv/) if you don't have it, then
installs the plugins into this folder only. Your other projects are not touched.

## Brief an atlas

In Claude Code, in this folder:

```
/atlas-brief https://datasets.cellxgene.cziscience.com/1ddf5a78-2994-4df8-a29e-824f2cf4c5d6.h5ad 10.1038/s41586-024-07944-6
```

That is the B-cell subset of the human thymus atlas (3,460 cells, 8 author
labels) and its Nature paper; it takes a few minutes. Any h5ad URL and any DOI,
PMID or citation work the same way. The first run is slower while the plugins'
tools download.

Optional, in a `.env` file or your shell: `PAPER_ACCESS_CONTACT_EMAIL` (otherwise
your `git config user.email` is used) and `ASTA_API_KEY` (one more route to the
paper's text).

## Reproducing a brief

A brief is reproducible from the commit it was made at. Commit
`projects/<atlas>/brief.md` and `cl_mapping.json` with the repo, and later:

```sh
git checkout <that commit>
./setup.sh
```

The workflow and the plugins are then exactly the versions that made it. What
this does not pin: Claude Code itself and the model, so record `claude --version`
and the model with the brief.

## Getting updates

```sh
git pull
./setup.sh
```

Then restart Claude Code.

## Windows, or without the script

Install uv ([instructions](https://docs.astral.sh/uv/getting-started/installation/)),
then in this folder: `uv run cs-plugin sync`.

## Single repo or two repos

The same workflow also exists split in two:
[atlas-workflows](https://github.com/ubyndr/atlas-workflows) holds `atlas-brief`
as a released plugin, and
[atlas-brief-project](https://github.com/ubyndr/atlas-brief-project) pins it
alongside the four plugins above.

| | This repo (single) | Two repos |
|---|---|---|
| Workflow lives in | `.claude/skills/` here | its own plugin repo, released with tags |
| Workflow version recorded by | this repo's commit / tag | `plugins.toml` (`atlas-brief = "0.1.0"`) |
| Fixing the workflow | edit, commit; users `git pull` | release a new version; each project runs `cs-plugin upgrade` |
| Projects made with *Use this template* | get a copy; later fixes never reach them | upgrade when they choose |
| Repos to maintain | one | two |

Single is enough while one repo is the place everyone works. Two repos pay off
once several projects or teams run the same workflow, each at its own version.

---

## For maintainers

Plugins are read from the repos under `[sources]` in `plugins.toml`, and
installed by [cs-plugin](https://github.com/ubyndr/cs-plugin), which is itself
pinned in `pyproject.toml` / `uv.lock`.

```sh
uv run cs-plugin list          # what is available, newest releases
uv run cs-plugin outdated      # pins with a newer release
uv run cs-plugin upgrade       # move pins to the newest releases
uv run cs-plugin sync          # install what is pinned, here
git add plugins.toml .claude .gitignore && git commit
```

To change the workflow, edit `.claude/skills/atlas-brief/SKILL.md`, commit, and
tag a new release of this repo (`v2`, …).

**cs-plugin on PyPI:** it is read from TestPyPI for now. Once it is on PyPI,
delete the `[[tool.uv.index]]` and `[tool.uv.sources]` blocks from
`pyproject.toml`, run `uv lock`, commit.
