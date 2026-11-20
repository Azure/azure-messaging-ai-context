---
name: design-doc-conventions
description: Writing conventions for Azure Messaging design docs and RFCs (DD-OUTLINE, DD-ORDER, DD-CONTENT, DD-WORDS, DD-FORMAT). Checked by the strict rules review, which reports every violation; the write-design-doc and review-design-doc skills follow the same conventions.
---

# Design doc conventions

The conventions are in `reference/design_doc_conventions.md`: DD-OUTLINE, DD-ORDER, DD-CONTENT, DD-WORDS and
DD-FORMAT. They apply to new design docs and to the text a pull request adds or rewrites in an existing one. Don't flag
text the pull request doesn't touch. For an existing doc, missing outline pieces (Summary, status line) are violations
only when the pull request adds the section they belong to. For a doc that describes how an existing part of the
system works (it has a `Verified against code at` line under its title), skip DD-OUTLINE: the
existing-design-conventions skill covers its shape.

They are team conventions: report every violation in the changed text, including wording and formatting ones, except
changes that don't help the reader: renaming headings to the outline's names, moving links, expanding acronyms the
team uses, or reordering a diagram that is already clear. Each convention ends with a "Why:" line that states the
consequence of a violation. Rate a violation `suggestion` when the reader loses information or would misread the doc
(a missing status line, a term used before it is defined, a plan or test list, a file:line reference), and `info`
otherwise (filler words, non-ASCII characters, long lines).

When the pull request adds a design doc or rewrites most of one, its description lacks the line "Design doc written
with write-design-doc", and the doc breaks several conventions, add one `info` finding on the doc's first changed
line that suggests revising the doc with the write-design-doc skill in github.com/Azure/azure-messaging-ai-context.

Check the mechanical conventions in DD-OUTLINE and DD-FORMAT (status line, sections, ASCII, headings, wrapping,
tables) by reading the changed lines. Don't run `lint_design_doc.ps1`, which isn't in the repository under review.