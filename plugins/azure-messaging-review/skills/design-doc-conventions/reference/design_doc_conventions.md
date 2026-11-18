---
name: design-doc-conventions
description: Conventions for Azure Messaging design docs and RFCs - outline, reading order, content, words and formatting.
applyTo:
  - "**/doc/design/**/*.md"
  - "**/*design*.md"
  - "**/*Design*.md"
  - "!**/design_doc_guidelines.md"
  - "!**/design_doc_conventions.md"
---

# Design doc conventions

These conventions decide how a design doc is written: its outline, reading order, content, words and formatting. The
design rules in [design_doc_guidelines.md](../../design-doc-guidelines/reference/design_doc_guidelines.md) decide
whether the design is right, and how to rate and revise after a review. The write-design-doc and review-design-doc
skills follow both files.

Each convention starts with a line of three dashes and its ID. Keep every convention in that form: Agency Review reads
any other top-level bullet in this file as a rule of its own.

---
# DD-OUTLINE
- Title: Use the standard outline
- Category: Structure
- Risk: Low
- State: Enabled

  Use these sections in this order. Skip a bracketed section when it has nothing to say. Add no other top-level
  sections.

  1. **Title**, then `Status: proposed (last updated YYYY-MM-DD)` while the design is not implemented. Update the
     date whenever the doc changes.
  2. **Summary:** the problem, the change, and its main consequence, in one or two short paragraphs.
  3. **Problem:** what breaks or costs too much today, with evidence (an ICM, a metric, numbers with units), and the
     constraints any solution must meet.
  4. **[How it works today]:** at most about five bullets with only the facts the Design section relies on; link
     existing docs for the rest.
  5. **Design:** the idea in one paragraph, a diagram of the main flow, then the details, hard parts first. For an
     RFC: the options with one line each, then each option in detail, a comparison, and the recommendation.
  6. **[Compatibility and rollout]:** only what an upgrade or rollback must do beyond a routine one, such as the
     order for starting to write a new on-disk or wire format.
  7. **[Testing]:** only non-obvious scenarios that prove the hard parts, each with its setup or fault and what must
     hold ("a node restart starts 8 builds at once; at most 2 run"). No test lists or mocking plans. Not in an RFC.
  8. **[Alternatives considered]:** each rejected option and why not. Not in an RFC.
  9. **[Open questions]:** decisions that the code and the available data can't settle. Write each question as a
     bullet and nest the answer you would pick under it.
  10. **[Appendix]:** optional reading such as data, derivations and long examples. The doc must make sense without
      it.
  11. **[References]:** links to related designs and to authoritative sources for well-known algorithms the design
      uses.

  Why: readers find the problem, the decision and the hard parts by these sections. Without the status line, readers
  take a proposal for how the system works today. Sections outside the outline usually hold content that goes stale (see
  DD-CONTENT).

---
# DD-ORDER
- Title: Make the doc read top to bottom
- Category: Readability
- Risk: Medium
- State: Enabled

  The doc reads top to bottom: introduce every term, component and section before using it, even within a section.
  When a section covers several options, components or cases, first list them, one line each, in the order it
  describes them. Describe a piece that every option shares before the options, not as one of them. Give each
  option a letter and a short name ("Option B: SF move") and refer to it by both ("SF move (Option B)"), never by the
  letter alone.

  Why: a term or option used before it is introduced makes the reader guess or skip ahead, and a bare option letter
  makes them look back to decode it.

---
# DD-CONTENT
- Title: Keep plans, tasks and history out of the doc
- Category: Structure
- Risk: Medium
- State: Enabled

  These belong in the PR description, the work item or the requirements doc, or nowhere:

  - Files, functions or modules to change; phases, PR plans, tasks, estimates.
  - Test lists, mocking plans, requirement IDs, approval checkboxes.
  - Work item, PR and ICM numbers (except as evidence for the problem), file:line references, dates other than the
    status line.
  - History: earlier versions, review discussion, "originally", "corrected", comparisons with other drafts.
  - Reasoning in progress ("Actually, let me reconsider"), notes to self, TBD sections.
  - Tutorials on external technology.

  Why: plans, test lists, IDs and history go stale as soon as the work moves on, and the doc then disagrees with the
  code and the work items.

---
# DD-WORDS
- Title: Use plain, precise words, and say each fact once
- Category: Readability
- Risk: Low
- State: Enabled

  - Define each new term in one plain sentence where it first appears. Introduce few new terms; use the code's
    names. Never invent codes (A0, G3) or new labels for things that already have a name.
  - Say each fact once. If two sections need it, link one to the other. When several cases behave the same, state
    the rule once and list only the exceptions.
  - Short, declarative, present-tense sentences in short paragraphs, one topic each.
  - Function names are verbs; don't turn them into nouns. Write "calls to `get_value`" or "reading the key", not
    "gets".
  - No filler or sales words ("it is important to note", "key insight", "robust", "seamless", "leverage",
    "comprehensive") and no stacked hedges ("may potentially").
  - Write never, always, guarantees or exactly only when the design enforces it, and say how.

  Why: filler and sales words cost reading time and hide the claim. An absolute the design doesn't enforce becomes a
  guarantee implementers rely on. A new name for something the code already names makes readers map names, and a fact
  stated twice drifts when one copy changes.

---
# DD-FORMAT
- Title: Format for plain-text readers
- Category: Readability
- Risk: Low
- State: Enabled

  - Markdown (bold, italics, code spans) is fine where it helps the reader, but the doc must also read well as plain
    text. ASCII characters only: no Unicode arrows, em-dashes, curly quotes, emoji or check marks.
  - `#` headings only (convert `===` and `---` underlines when editing a doc), at most 3 levels, unnumbered.
  - Wrap prose and lists at 120 characters.
  - Prefer lists. Keep each top-level bullet to one line. Nest details when there are several; fold a single short
    reason into the line. Give options, alternatives and cases a short bold label:
    ```
    - **Expire only on read (no sweeper):**
        - Reading an expired key deletes it.
        - Keys that are never read again, the case this change is for, stay forever.
    ```
  - Diagrams in mermaid, never ASCII art: sequence diagrams for interactions, flowcharts for layers or states. Show
    only the participants that matter, keep diagrams consistent with the text and each other, and don't repeat a
    diagram's steps as a list.
  - Use a table only for a byte layout or to compare several items on the same attributes, when every cell is a few
    words. Align its columns in plain text. If a cell needs a sentence, use a list.

  Why: reviewers read the doc in plain-text diffs and terminals. Non-ASCII characters show as "?" or garbled text in
  many of those tools and break search, ASCII art and long lines break when rewrapped, and a table cell that holds a
  sentence is unreadable in plain text.
