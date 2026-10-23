---
name: atlas-brief
description: Brief a single-cell atlas from its h5ad URL and its paper — the authors' own cell-type labels with cell counts, each mapped to a Cell Ontology term and backed by a verbatim quote from the atlas paper. Use when someone gives an atlas (h5ad URL) and its publication (DOI, PMID or citation) and asks what cell types it has, what the authors meant by them, or how they map to CL.
argument-hint: <h5ad-url> <paper DOI | PMID | citation>
---

# atlas-brief

A workflow, not a capability: every step is done by a skill from another plugin,
pinned in this repo's `plugins.toml`. This file only says
the order, what to hand from one step to the next, and what the brief must hold.

| step | skill (plugin) |
|---|---|
| 1. read obs | `remote-h5ad-obs` (remote-h5ad-obs) |
| 2. pick the author cell-type column | `author-annotation-columns` (author-annotation-columns) |
| 3. get the paper | `paper-access` (paper-access) |
| 4. map labels to CL | `map-to-ontology` (onto-mapping) |

If one of those skills is not available, stop and say which: the project's
plugins are not installed (`./setup.sh`). Do not do its job by hand.

## Inputs

`$ARGUMENTS` is an h5ad URL and the atlas paper. Ask for whichever is missing.
Make a short slug for the atlas (e.g. `thymus-b-cells`) and write everything
under `projects/<slug>/`:

```
projects/<slug>/
  obs.parquet          step 1
  profile.txt          step 2
  papers/              step 3, the paper-access store
  cl_mapping.json      step 4
  brief.md             the output
```

## Steps

1. **Read obs once.** Follow `remote-h5ad-obs` to pull the whole obs table to
   `projects/<slug>/obs.parquet`. Every later step reads this file, never the URL.
2. **Author cell-type column.** Follow `author-annotation-columns` with
   `field_type` `cell_type`. Take the finest-grained column it picks, and count
   cells per label. If the portal's standardised `cell_type` column is present,
   keep its label per author label too: it is the portal's own CL mapping, and a
   cross-check for step 4.
3. **The paper.** Follow `paper-access` with the store at
   `projects/<slug>/papers/`. Record which route it arrived by. If no full text
   arrives, say so in the brief and continue without quotes rather than quoting
   from memory.
4. **Map to CL.** Follow `map-to-ontology` for every author label, as one batch,
   using what the paper says about the label as context. Write the per-label
   reports to `cl_mapping.json`.
5. **Write `brief.md`.**

## brief.md

- A header: atlas URL, paper identifier and title, how the paper was retrieved,
  the author column used, total cells, and the date.
- One table row per author label, most cells first:
  `label | cells | CL term (id) | portal CL | agrees? | quote`.
- **quote** is a sentence copied verbatim from the paper's text that says what
  the authors mean by the label, with its section. Copy it from the retrieved
  file; never paraphrase into quotation marks. No quote found is a valid cell:
  write `—` and say so below the table.
- Below the table: every label where the mapping disagrees with the portal's CL
  term, or where `map-to-ontology` was not confident, with one line of reason.

Show the user the table when done, and the path to `brief.md`.
