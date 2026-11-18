---
name: design-doc-guidelines
description: Design rules for Azure Messaging design docs and RFCs - doc type, design completeness and depth.
applyTo:
  - "**/doc/design/**/*.md"
  - "**/*design*.md"
  - "**/*Design*.md"
  - "!**/design_doc_guidelines.md"
  - "!**/design_doc_conventions.md"
---

# Design doc guidelines

A design doc lets a teammate who knows the system understand the problem, the decision and the hard parts in one
read, and lets an implementer (a person or an agent) build it without guessing at behavior. It is not an
implementation plan, an API reference, or a record of how the design evolved.

These rules decide whether the design is right. The conventions in
[design_doc_conventions.md](../../design-doc-conventions/reference/design_doc_conventions.md) decide how the doc is
written: its outline, reading order, content, words and formatting. The write-design-doc and review-design-doc skills
follow both files, and Agency Review applies them to pull requests that change a design doc.

Each rule starts with a line of three dashes and its ID. Keep every rule in that form: Agency Review reads any other
top-level bullet in this file as a rule of its own.

---
# DD-TYPE
- Title: Pick one doc type, and write one doc per decision
- Category: Structure
- Risk: Medium
- State: Enabled

  - **RFC:** the problem is clear, the solution is not. Compare options in only as much depth as the comparison
    needs, and recommend one.
  - **New component or feature:** its purpose, how a caller uses it, how it works, the new API, and its guarantees.
    When it extends a system with a design doc, link that doc instead of restating it, and add to it a short section
    with "(proposed)" in its heading and a status line under it: how that part works today if the doc doesn't say,
    the change in two or three sentences, and a link. Leave the existing doc's own status line alone.
  - **Change to existing behavior:** edit the existing design doc in place so it describes the design after the
    change. Keep its outline and apply these rules to the text you add or rewrite. If the change needs its own
    problem statement, alternatives or rollout, treat it as a new feature instead.

  A doc that needs two types, or makes two independent decisions, should be two docs.

  Why: a doc that mixes types or decisions can't be approved or rejected as a whole, and readers can't tell which parts
  are settled.

---
# DD-DESIGN
- Title: Decide every behavior, and match the code
- Category: Correctness
- Risk: High
- State: Enabled

  - The design solves the stated problem within its constraints, and doesn't miss a simpler way.
  - Every behavior is decided, and no two statements contradict each other.
  - Failure and recovery, concurrency and ordering, limits, compatibility and rollback are covered wherever the
    design touches them.
  - Every claim about existing code or other systems matches the code. Name the module, not file:line.

  Why: an implementer builds what the doc says, so an undecided behavior, a contradiction or a wrong claim about the
  code becomes a bug or a guess.

---
# DD-DEPTH
- Title: Spend words only where an implementer could go wrong
- Category: Readability
- Risk: Medium
- State: Enabled

  - Keep the core, Summary through Testing, under 2,500 words. A longer core usually restates existing behavior or
    spells out what an implementer would do anyway. Cut it, or split the design.
  - Write for a teammate who knows the system. Before keeping a sentence, ask whether it is obvious from how the
    system already works and whether an implementer would find it anyway in existing docs. If both, cut it. If an
    obvious consequence is worth stressing, fold it into its sentence instead of adding sentences about it. Leave
    out what the reader can derive, such as a name that follows a stated pattern or what a caller can do about an
    error.
  - Spend words where an implementer could go wrong: concurrency, ordering, failure and recovery, formats and
    compatibility, limits. Routine plumbing (argument checks, logging) gets a line at most; failure behavior is
    design, not plumbing. List metric and config names as bullets.
  - Stop when every behavior is decided. Internal structure (helper functions, file layout, internal locking)
    belongs in the code and the requirements doc, unless it is the hard part.
  - Give the reason for a choice in the Design only when it isn't obvious, in a clause or a sentence. Arguments
    against other choices ("X instead would ...") go under Alternatives considered.
  - Code only for new or changed public signatures and structs needed to state a contract. Show an interface once,
    where it is defined (the RPC, not each client that mirrors it). No function bodies, before/after diffs, or
    pseudo-code for straightforward logic.
  - Describe a change to a format as the difference ("v4 plus `expires_at`, 8 bytes, after the incarnation id") and
    link the layout. Show a new layout as a table with a column per field and a row of sizes, like existing layouts.
  - Existing behavior gets a sentence and a link. Don't re-document existing modules, external libraries or an
    earlier phase.
  - Name a well-known algorithm when the design uses one, explain what the design needs from it, and link a source
    under References.
  - Give every number a source and a unit. Add no optimization without evidence that it is needed.

  Why: restated existing behavior drifts from the code and buries the decisions, and missing detail where an implementer
  could go wrong leaves them guessing.

## Rating review findings

Keep a finding only if it costs the reader: confusion, wasted reading, or guessing at behavior. Skip changes that
don't help the reader: renaming headings to the outline's names, moving links, expanding acronyms the team uses, or
reordering a diagram that is already clear. Give each finding the rule it breaks and a concrete fix: a rewrite,
"delete", "move", or the design change. Rate it:

1. **Blocking:** a design bug or gap, a claim that contradicts the code, a reader who can't tell the problem or the
   decision or has to guess at behavior, or content that doesn't belong (test lists, plans, file lists).
2. **Question:** a design risk or alternative worth discussing that is not a bug.
3. **Cut:** text that can be deleted or shortened without losing information.
4. **Nit:** everything else, such as one unclear sentence. For an existing doc, missing outline pieces (Summary,
   status line) are nits.

## Revising after review

1. Edit in place: rewrite the text a comment is about instead of adding a paragraph or section. A question about a
   sentence usually means the sentence is unclear.
2. A wording or clarity comment should not grow the doc. A comment that changes or adds design gets the depth a first
   draft would (see DD-DEPTH), and only that.
3. Fix what each comment asks for everywhere it applies, including every section a design change affects, and nothing
   else. Don't restructure or reformat text that no comment is about, even where it breaks these rules; a rewrite is
   a separate change.
4. Check a reviewer's claim before agreeing with it.
5. Reread the whole doc and remove text your edits made stale, duplicated or contradictory.
6. Reply in 3 sentences or fewer with what changed. Explanations a future reader needs go in the doc.

## Review checklist

1. Run the write-design-doc skill's `lint_design_doc.ps1` on the doc (`-Existing` for an existing doc being edited).
   It checks the mechanical rules: ASCII, headings, line length and wrapping, tables, status lines, outline, core
   length.
2. List every other violation of the rules above and of the conventions.
3. Do any two statements contradict each other?
4. After the Summary, can a teammate state the problem and the decision?
5. Which sentences could be deleted or shortened without losing information?
6. Can the core be read in one sitting? Cut or move to the appendix any section longer than its importance.
