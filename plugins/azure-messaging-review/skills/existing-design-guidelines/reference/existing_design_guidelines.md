---
name: existing-design-guidelines
description: Rules for Azure Messaging design docs that describe how an existing part of the system works today - accuracy against the code, and depth.
applyTo:
  - "**/doc/design/**/*.md"
  - "**/*design*.md"
  - "**/*Design*.md"
  - "!**/design_doc_guidelines.md"
  - "!**/design_doc_conventions.md"
  - "!**/existing_design_guidelines.md"
  - "!**/existing_design_conventions.md"
---

# Existing design guidelines

An existing-design doc explains how one part of the system works today and how its pieces fit together: the whole
system, a layer, a subsystem, or occasionally one module. Such docs form a tree. Each doc covers what its pieces share
and how they interact, and links down to the docs for its pieces, so a reader starts at the top and drills down only as
far as they need. A module's requirements doc (or its code documentation) is the leaf that holds the detail.

These rules apply only to a doc that describes how an existing part of the system works, which has a
`Verified against code at` line under its title. A doc that proposes a change follows the design doc guidelines
instead. These rules decide whether the doc describes the code correctly and at the right depth. The conventions in
[existing_design_conventions.md](../../existing-design-conventions/reference/existing_design_conventions.md) decide its
shape, links and diagrams, and the shared conventions DD-ORDER, DD-CONTENT, DD-WORDS and DD-FORMAT in
[design_doc_conventions.md](../../design-doc-conventions/reference/design_doc_conventions.md) decide its words and
formatting. The document-existing-design and review-design-doc skills follow all three files.

Each rule starts with a line of three dashes and its ID. Keep every rule in that form: Agency Review reads any other
top-level bullet in this file as a rule of its own.

---
# ED-CODE
- Title: Describe the code as it is today
- Category: Correctness
- Risk: High
- State: Enabled

  - Describe what the code does today, in the present tense. The code is the source of truth: follow it from the
    callers down, and check what older docs and headers say against the call sites.
  - A module that only tests create is not part of the design yet; list it under Future work.
  - No history ("originally", "was replaced") and no record of the doc's edits. Before Future work, which describes
    planned parts, no proposal language ("will", "proposes"), and every identifier in backticks exists in the code.
  - A shipped feature is part of the design: describe it where it belongs instead of linking a separate feature doc.

  Why: readers trust this doc to describe the running system. A stale name, a design that was never built, or unused
  code shown as live sends them to code that doesn't exist or behaves differently.

---
# ED-DEPTH
- Title: Explain how the pieces fit, and leave detail to the leaves
- Category: Readability
- Risk: Medium
- State: Enabled

  - Keep each doc short: its core, everything before Future work, under 1,500 words. When one piece needs more than a
    few paragraphs, give it its own doc and link it.
  - Name modules, and functions only at the part's entry points; other function names change too often.
  - Leave detail to the leaves: per-function behavior, config fields, byte layouts and lock-by-variable tables belong
    in the requirements. Link them instead.

  Why: a doc that restates its leaves goes stale with every code change and hides how the pieces fit together.
