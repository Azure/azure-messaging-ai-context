---
name: existing-design-conventions
description: Conventions for Azure Messaging design docs that describe how an existing part of the system works today - shape, links and diagrams.
applyTo:
  - "**/doc/design/**/*.md"
  - "**/*design*.md"
  - "**/*Design*.md"
  - "!**/design_doc_guidelines.md"
  - "!**/design_doc_conventions.md"
  - "!**/existing_design_guidelines.md"
  - "!**/existing_design_conventions.md"
---

# Existing design conventions

These conventions decide the shape, links and diagrams of a doc that describes how an existing part of the system
works, which has a `Verified against code at` line under its title. The rules in
[existing_design_guidelines.md](../../existing-design-guidelines/reference/existing_design_guidelines.md) decide
whether it describes the code correctly and at the right depth. A doc that proposes a change follows the design doc
conventions' DD-OUTLINE instead of ED-SHAPE.

Each convention starts with a line of three dashes and its ID. Keep every convention in that form: Agency Review reads
any other top-level bullet in this file as a rule of its own.

---
# ED-SHAPE
- Title: Start with the header, then build from concepts to components to flows
- Category: Structure
- Risk: Low
- State: Enabled

  - Fit the doc to the tree the repo already has. Keep an existing doc's name and place when rewriting it, and put a
    new doc where the repo keeps similar docs.
  - Start with the title, then `Parent: [name](link)` unless the doc is a root, then
    `Verified against code at <short commit> (YYYY-MM-DD)`, updated whenever someone checks the doc against the code.
  - This shape usually reads well. Adapt it to the part, and keep each sub-section to a few sentences or bullets:
    1. **Summary:** what the part does for its callers, what it includes, and where it sits in the system.
    2. **Core concepts:** the terms and ideas the rest of the doc uses, one or two sentences each, ordered so each
       builds on the ones before (for a storage index: blocks and keys, then operations and their log addresses,
       then local and offloaded entries). A concept the whole part rests on, such as how its data is laid out or
       stored, may get its own sub-section and diagram. Define concepts here; explain how they work under the piece
       that owns them.
    3. **Components or layers:** a diagram of the pieces, then a sub-section per piece: its responsibility, how it
       does its share of the work, and a link to its own doc, or to its requirements when it has none. Group related
       pieces under one sub-section with a nested sub-section or bullet each, and a small diagram of what passes
       between them when that isn't obvious.
    4. **Flows:** the flows that cross pieces, each a sequence diagram plus a few sentences on what the diagram can't
       show.
    5. **[Cross-cutting topics]:** what no single piece owns, such as threading, failure and recovery, or lifecycles,
       a sub-section each.
    6. **[Future work]:** parts that are planned, partly built, or written but unused, one line each, linked to their
       design.
    7. **[References]:** related docs, including design docs that explain why the part was built this way.
    8. **[Appendix]:** optional reading. The doc must make sense without it.
  - No Problem, Alternatives, Open questions or Testing sections; those belong to proposals.

  Why: the header tells readers where the doc sits in the tree and how fresh it is. Concepts first, then pieces, then
  flows lets them read top to bottom: each section uses only terms and pieces already introduced. Proposal sections
  make readers take the doc for a plan.

---
# ED-LINKS
- Title: Link the tree both ways
- Category: Structure
- Risk: Low
- State: Enabled

  - Link every piece's doc from its sub-section, and link back to the parent.
  - Link a piece's existing design doc only if it is current; otherwise link its requirements.

  Why: a doc nothing links to is never found, and a link to a stale doc teaches the reader a design that no longer
  exists.

---
# ED-DIAGRAMS
- Title: Draw the pieces and flows at the doc's level
- Category: Readability
- Risk: Low
- State: Enabled

  - One diagram of the pieces: for a part built in layers, the layer stack from top to bottom; otherwise pieces as
    boxes and calls as arrows from caller to callee, with subgraphs for layers or roles (primary only, client side). At
    most about 12 boxes; group the rest into pieces with their own doc.
  - Sequence diagrams at the doc's level: the participants are the pieces the doc describes, not functions, and not
    groups of pieces it describes separately. One diagram per flow. Show where work moves to another thread or
    completes asynchronously when it matters.
  - State diagrams for lifecycles such as roles or open and close.
  - Use the same names in diagrams, text and code.

  Why: a diagram at the wrong level, or with names that differ from the text, makes readers map one onto the other
  instead of seeing how the pieces fit.
