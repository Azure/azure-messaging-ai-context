# Design doc guidelines

A design doc lets a teammate who knows the system understand the problem, the decision and the hard parts in one
read, and lets an implementer (a person or an agent) build it without guessing at behavior. It is not an
implementation plan, an API reference, or a record of how the design evolved.

## Doc types

- **RFC:** the problem is clear, the solution is not. Compare options in only as much depth as the comparison needs,
  and recommend one.
- **New component or feature:** its purpose, how a caller uses it, how it works, the new API, and its guarantees.
- **Change to an existing system:** how it works today, what changes, and how old and new versions coexist. Write it
  as a new doc that links to the existing design doc instead of restating it. In the existing doc, add one short
  section with "(proposed)" in its heading and its own status line under it: how that part works today if the doc
  doesn't say, the change in two or three sentences, and a link. Leave the existing doc's own status line alone.

A doc that needs two types, or makes two independent decisions, should be two docs.

## Outline

Use these sections in this order. Skip a bracketed section when it has nothing to say. Add no other top-level
sections.

1. **Title**, then `Status: proposed (last updated YYYY-MM-DD)` while the design is not implemented. Update the date
   whenever the doc changes.
2. **Summary:** the problem, the change, and its main consequence, in one or two short paragraphs.
3. **Problem:** what breaks or costs too much today, with evidence (an ICM, a metric, numbers with units), and the
   constraints any solution must meet.
4. **[How it works today]:** a few bullets with only the facts the Design section relies on; link existing docs for
   the rest.
5. **Design:** the idea in one paragraph, a diagram of the main flow, then the details, hard parts first. For an RFC:
   the options with one line each, then each option in detail, a comparison, and the recommendation.
6. **[Compatibility and rollout]:** when on-disk, wire or config formats change, or versions run side by side:
   deployment order, what mixed versions do, and how to roll back. Only what differs from a routine upgrade and
   rollback; skip the section if nothing does.
7. **[Testing]:** only non-obvious scenarios that prove the hard parts, each with its setup or fault and what must
   hold ("a node restart starts 8 builds at once; at most 2 run"). No test lists or mocking plans. Not in an RFC.
8. **Alternatives considered:** each rejected option and why not. Not in an RFC.
9. **[Open questions]:** decisions that the code and the available data can't settle. Write each question as a
   bullet and nest the answer you would pick under it.
10. **[Appendix]:** optional reading such as data, derivations and long examples. The doc must make sense without it.
11. **[References]:** links to related designs and to authoritative sources for well-known algorithms the design uses.

The doc reads top to bottom: introduce every term, component and section before using it, even within a section.
When a section covers several options, components or cases, first list them with one line each, in the order the
section then describes them. Describe a piece that every option shares before the options, not as one of them. Give
each option a letter and a short name ("Option B: SF move") and refer to it by both ("SF move (Option B)"), never by
the letter alone.

## Depth

- Write for a teammate who knows the system. Before keeping a sentence, ask whether it is obvious from how the system
  already works and whether an implementer would find it anyway in existing docs. If both, cut it. If an obvious
  consequence is worth stressing, fold it into its sentence ("stores `expires_at` in the set value operation, so it is
  replicated and persisted") instead of adding sentences about it.
- Spend words where an implementer could go wrong: concurrency, ordering, failure and recovery, formats and
  compatibility, limits. Routine plumbing (argument checks, logging) gets a line at most; failure behavior is design,
  not plumbing. List metric and config names as bullets.
- Stop when every behavior is decided. Internal structure (helper functions, file layout, internal locking) belongs
  in the code and the requirements doc, unless it is the hard part.
- Code only for new or changed public signatures, on-disk or wire formats, and structs needed to state a contract. No
  function bodies, before/after diffs, or pseudo-code for straightforward logic.
- Existing behavior gets a sentence and a link. Don't re-document existing modules, external libraries or an earlier
  phase.
- Name a well-known algorithm when the design uses one, explain what the design needs from it, and link a source under
  References.
- Give every number a source and a unit. Add no optimization without evidence that it is needed.

## Not in a design doc

These belong in the PR description, the work item or the requirements doc, or nowhere:

- Files, functions or modules to change; phases, PR plans, tasks, estimates.
- Test lists, mocking plans, requirement IDs, approval checkboxes.
- Work item, PR and ICM numbers (except as evidence for the problem), file:line references, dates other than the
  status line.
- History: earlier versions, review discussion, "originally", "corrected", comparisons with other drafts.
- Reasoning in progress ("Actually, let me reconsider"), notes to self, TBD sections.
- Tutorials on external technology.
- Notes about this design wedged into another doc's text. Give them their own short section (see Doc types).

## Words

- Define each new term in one plain sentence where it first appears. Introduce few new terms; use the code's names.
  Never invent codes (A0, G3) or new labels for things that already have a name.
- Say each fact once. If two sections need it, link one to the other.
- Short, declarative, present-tense sentences in short paragraphs, one topic each.
- Function names are verbs; don't turn them into nouns. Write "calls to `get_value`" or "reading the key", not "gets".
- No filler or sales words ("it is important to note", "key insight", "robust", "seamless", "leverage",
  "comprehensive") and no stacked hedges ("may potentially").
- Write never, always, guarantees or exactly only when the design enforces it, and say how.
- Check every claim about existing code or other systems against the code. Name the module, not file:line.

## Formatting

- Markdown (bold, italics, code spans) is fine where it helps the reader, but the doc must also read well as plain
  text. ASCII characters only: no Unicode arrows, em-dashes, curly quotes, emoji or check marks.
- `#` headings only (convert `===` and `---` underlines when editing a doc), at most 3 levels, unnumbered.
- Wrap prose and lists at 120 characters.
- Prefer lists. Keep each top-level bullet to one line and nest its details. Give options, alternatives and cases a
  short bold label:
  ```
  - **Expire only on read (no sweeper):**
      - Reading an expired key deletes it.
      - Keys that are never read again, the case this change is for, stay forever.
  ```
- Diagrams in mermaid, never ASCII art: sequence diagrams for interactions, flowcharts for layers or states. Show only
  the participants that matter, keep diagrams consistent with the text and each other, and don't repeat a diagram's
  steps as a list.
- Use a table only to compare several items on the same attributes, when every cell is a few words. Align its columns
  in plain text. If a cell needs a sentence, use a list.

## Revising after review

- Edit in place: rewrite the text a comment is about instead of adding a paragraph or section. A question about a
  sentence usually means the sentence is unclear.
- A review round should not grow the doc; if it must, say why.
- Change only what the comment asks for.
- If a comment changes the design, revise the whole doc, not just the section it is on.
- Check a reviewer's claim before agreeing with it.
- Reread the whole doc and remove text your edits made stale, duplicated or contradictory.
- Reply in 3 sentences or fewer with what changed. Explanations a future reader needs go in the doc.

## Review checklist

1. Run [lint_design_doc.ps1](lint_design_doc.ps1) on the doc (`-Existing` for an existing doc being edited). It
   checks the mechanical rules: ASCII, headings, line length, tables, status line, outline.
2. List every other violation of the rules above.
3. Do any two statements contradict each other?
4. After the Summary, can a teammate state the problem and the decision?
5. Which sentences could be deleted or shortened without losing information?
6. Can the core be read in one sitting? Cut or move to the appendix any section longer than its importance.
