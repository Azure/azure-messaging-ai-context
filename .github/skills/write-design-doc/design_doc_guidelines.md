# Design doc guidelines

A design doc lets a teammate who knows the system understand the problem, the decision and the hard parts in one
read, and lets an implementer (a person or an agent) build it without guessing at behavior. It is not an
implementation plan, an API reference, or a record of how the design evolved.

## Doc types

- **RFC:** the problem is clear, the solution is not. Compare options in only as much depth as the comparison needs,
  and recommend one.
- **New component or feature:** its purpose, how a caller uses it, how it works, the new API, and its guarantees.
- **Change to an existing system:** how it works today, what changes, and how old and new versions coexist.

A doc that needs two types, or makes two independent decisions, should be two docs.

## Outline

Use these sections in this order. Skip a bracketed section when it has nothing to say. Add no other top-level
sections.

1. **Title**, then `Status: proposed` if the design is not implemented yet.
2. **Summary:** 3 to 5 sentences: the problem, the change, and its main consequence.
3. **Problem:** what breaks or costs too much today, with evidence (an ICM, a metric, numbers with units), and the
   constraints any solution must meet.
4. **[How it works today]:** only what the reader needs to follow the change; link existing docs for the rest.
5. **Design:** the idea in one paragraph, a diagram of the main flow, then the details, hard parts first. For an RFC:
   each option, a comparison, and the recommendation.
6. **[Compatibility and rollout]:** when on-disk, wire or config formats change, or versions run side by side:
   deployment order, what mixed versions do, and how to roll back.
7. **[Testing]:** only non-obvious scenarios that prove the hard parts ("a node restart starts 8 builds at once"). No
   test lists.
8. **Alternatives considered:** a short paragraph per rejected option: what it is and why not. Not needed in an RFC.
9. **[Open questions]:** decisions still open, each with the answer you would pick.
10. **[Appendix]:** optional reading such as data, derivations and long examples. The doc must make sense without it.

The doc reads top to bottom: introduce every term, component and section before using it.

## Depth

- Spend words where an implementer could go wrong: concurrency, ordering, failure and recovery, formats and
  compatibility, limits. Routine plumbing (argument checks, logging, metric wiring) gets a line at most.
- Stop when every behavior is decided. Internal structure (helper functions, file layout, internal locking) belongs
  in the code and the requirements doc, unless it is the hard part.
- Code only for new or changed public signatures, on-disk or wire formats, and structs needed to state a contract. No
  function bodies, before/after diffs, or pseudo-code for straightforward logic.
- Existing behavior gets a sentence and a link. Don't re-document existing modules, external libraries or an earlier
  phase.
- Give every number a source and a unit. Add no optimization without evidence that it is needed.

## Not in a design doc

These belong in the PR description, the work item or the requirements doc, or nowhere:

- Files, functions or modules to change; phases, PR plans, tasks, estimates.
- Test lists, mocking plans, requirement IDs, approval checkboxes.
- Work item, PR and ICM numbers (except as evidence for the problem), file:line references, dates.
- History: earlier versions, review discussion, "originally", "corrected", comparisons with other drafts.
- Reasoning in progress ("Actually, let me reconsider"), notes to self, TBD sections.
- Tutorials on external technology.

## Words

- Define each new term in one plain sentence where it first appears. Introduce few new terms; use the code's names.
  Never invent codes (A0, G3) or new labels for things that already have a name.
- Say each fact once. If two sections need it, link one to the other.
- Short, declarative, present-tense sentences: "The replica releases the slot when the copy completes."
- No filler or sales words ("it is important to note", "key insight", "robust", "seamless", "leverage",
  "comprehensive") and no stacked hedges ("may potentially").
- Write never, always, guarantees or exactly only when the design enforces it, and say how.
- Check every claim about existing code or other systems against the code. Name the module, not file:line.
- No bold-led paragraphs or bold for emphasis. At most 3 heading levels, unnumbered.

## Formatting

- ASCII characters only: no Unicode arrows, em-dashes, curly quotes, emoji or check marks.
- Diagrams in mermaid, never ASCII art: sequence diagrams for interactions, flowcharts for layers or states. Show only
  the participants that matter, keep diagrams consistent with the text and each other, and don't repeat a diagram's
  steps as a list.
- Prefer lists and nested lists. Use a table only to compare several items on the same attributes, with its columns
  aligned in plaintext.

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

1. List every violation of the rules above.
2. After the Summary, can a teammate state the problem and the decision?
3. Which paragraphs could be deleted or shortened without losing information?
4. Can the core be read in one sitting? Cut or move to the appendix any section longer than its importance.
