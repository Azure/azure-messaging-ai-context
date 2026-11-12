---
name: review-design-doc
description: Review a design doc or RFC, both its design (correctness, gaps, risks) and its readability (structure, length, level of detail). Use when asked to review a design doc, design PR or RFC, or to check whether a design doc is easy to read.
---

# Review a design doc

Use [design_doc_guidelines.md](../write-design-doc/design_doc_guidelines.md). Do both passes unless the user asks for
one.

1. Read the doc once, top to bottom, as a teammate who knows the system but not this change. Note where you got lost,
   had to reread, or skimmed.
2. **Design pass.** Read the code and docs the change touches, then ask:
   - Does the design solve the stated problem within its constraints? Is there a simpler way?
   - Do its claims about existing code and other systems match the code?
   - What is wrong or missing in failure and recovery, concurrency and ordering, limits, compatibility and rollback?
   - Is any behavior undecided, or do two statements contradict each other?
3. **Readability pass.** Run the review checklist. Keep a finding only if it costs the reader: confusion, wasted
   reading, or guessing at behavior. Skip changes that don't help the reader: renaming headings to the outline's
   names, moving links, expanding acronyms the team uses, or reordering a diagram that is already clear.
4. Give each finding its location (heading and line), the problem, and a concrete fix: a rewrite, "delete", "move",
   or the design change. Rate it:
   - **Blocking:** a design bug or gap, a claim that contradicts the code, a reader who can't tell the problem or the
     decision or has to guess at behavior, or content that doesn't belong (test lists, plans, file lists).
   - **Question:** a design risk or alternative worth discussing that is not a bug.
   - **Cut:** text that can be deleted or shortened without losing information.
   - **Nit:** everything else, such as one unclear sentence. For an existing doc, missing outline pieces (Summary,
     status line) are nits.
5. Report:
   - A verdict in 3 lines or fewer: is the design sound, is it readable, the biggest problems, and roughly how long
     the doc would be after the cuts. When reviewing a PR whose description lacks the write-design-doc attribution
     line and whose doc breaks several guidelines, suggest revising it with the write-design-doc skill.
   - Findings ranked within each rating, design findings first. Report the lint output as one nit.
   - If the doc is good, say so; a good doc gets few findings.
6. Post comments on a PR only if the user asks; otherwise report to the user.
