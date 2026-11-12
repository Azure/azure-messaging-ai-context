---
name: review-design-doc
description: Review a design doc or RFC for readability, structure and level of detail. Use when asked to review a design doc, design PR or RFC, or to check whether a design doc is easy to read.
---

# Review a design doc

Use [design_doc_guidelines.md](../write-design-doc/design_doc_guidelines.md).

1. Read the doc once, top to bottom, as a teammate who knows the system but not this change. Note where you got lost,
   had to reread, or skimmed.
2. Run the review checklist. Keep a finding only if it costs the reader: confusion, wasted reading, or guessing at
   behavior. Give its location (heading and line), the problem, and a concrete fix: a rewrite, "delete", or "move".
3. Rate each finding:
   - **Blocking:** the reader can't tell the problem or the decision, has to guess at behavior, or the doc contains
     content that doesn't belong (test lists, plans, file lists).
   - **Cut:** text that can be deleted or shortened without losing information.
   - **Nit:** everything else, such as one unclear sentence. For an existing doc, missing outline pieces (Summary,
     status line) are nits.
4. Skip changes that don't help the reader: renaming headings to the outline's names, moving links, expanding
   acronyms the team uses, or reordering a diagram that is already clear.
5. Report:
   - A verdict in 3 lines or fewer: is it readable, the biggest problems, and roughly how long it would be after the
     cuts.
   - Findings ranked within each rating. Report the lint output as one nit.
   - If the doc reads well, say so; a good doc gets few findings.
6. Technical correctness is out of scope, except claims that contradict the code or each other: flag those.
7. Post comments on a PR only if the user asks; otherwise report to the user.
