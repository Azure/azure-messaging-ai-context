---
name: review-design-doc
description: Review a design doc or RFC, both its design (correctness, gaps, risks) and its readability (structure, length, level of detail). Use when asked to review a design doc, design PR or RFC, or to check whether a design doc is easy to read.
---

# Review a design doc

Use [design_doc_guidelines.md](../../../plugins/azure-messaging-review/skills/design-doc-guidelines/reference/design_doc_guidelines.md)
and [design_doc_conventions.md](../../../plugins/azure-messaging-review/skills/design-doc-conventions/reference/design_doc_conventions.md),
the same rules the pull request reviews apply to a change to a design doc. Do both passes unless the user asks for one.

For a doc that describes how an existing part of the system works (it has a `Verified against code at` line, or
documents how a part works today), use
[existing_design_guidelines.md](../../../plugins/azure-messaging-review/skills/existing-design-guidelines/reference/existing_design_guidelines.md)
and [existing_design_conventions.md](../../../plugins/azure-messaging-review/skills/existing-design-conventions/reference/existing_design_conventions.md)
in place of DD-TYPE, DD-OUTLINE, DD-DESIGN and DD-DEPTH. Its design pass checks every claim against ED-CODE, and the
skill to suggest is document-existing-design.

1. Read the doc once, top to bottom, as a teammate who knows the system but not this change. Note where you got lost,
   had to reread, or skimmed.
2. **Design pass.** Read the code and docs the change touches, then check the doc against DD-DESIGN.
3. **Readability pass.** Run the review checklist.
4. Give each finding its location (heading and line), the rule it breaks, the problem, and a concrete fix, and rate it
   as described in "Rating review findings".
5. Report:
   - A verdict in 3 lines or fewer: is the design sound, is it readable, the biggest problems, and roughly how long
     the doc would be after the cuts. When reviewing a PR whose description lacks the write-design-doc attribution
     line and whose doc breaks several guidelines, suggest revising it with the write-design-doc skill.
   - Findings ranked within each rating, design findings first. Report the lint output as one nit.
   - If the doc is good, say so; a good doc gets few findings.
6. Post comments on a PR only if the user asks; otherwise report to the user.
