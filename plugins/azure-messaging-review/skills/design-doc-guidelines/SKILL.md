---
name: design-doc-guidelines
description: Rules for Azure Messaging design docs and RFCs (DD-TYPE to DD-FORMAT), and how to rate review findings against them. Loaded by Agency Review as a guideline source; the write-design-doc and review-design-doc skills use the same rules.
---

# Design doc guidelines

The rules are in `reference/design_doc_guidelines.md`, from DD-TYPE to DD-FORMAT. They apply to new design docs and
to the text a pull request adds or rewrites in an existing one. Don't flag text the pull request doesn't touch.

Rate findings as described in "Rating review findings" at the end of the rules file, and map the rating to the
Agency Review severity as follows: Blocking is `blocking`, Question and Cut are `suggestion`, and Nit is `info`. A
design doc has no runtime failure path, so a Blocking finding is one that leaves the reader unable to build the
design correctly: a design bug or gap, a claim that contradicts the code, an undecided behavior, or content that
belongs in a work item or the requirements doc. Each rule ends with a "Why:" line; a violation has that consequence
for the reader, so report it at least as a Nit (`info`).

The review checklist at the end of the rules file is for the review-design-doc skill. Don't run
`lint_design_doc.ps1`, which isn't in the repository under review: check the mechanical rules in DD-OUTLINE and
DD-FORMAT (status line, sections, ASCII, headings, wrapping, tables) by reading the changed lines.
