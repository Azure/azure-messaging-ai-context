---
name: review-design-doc
description: Review a design doc or RFC for readability, structure and level of detail. Use when asked to review a design doc, design PR or RFC, or to check whether a design doc is easy to read.
---

# Review a design doc

Use [design_doc_guidelines.md](../write-design-doc/design_doc_guidelines.md).

1. Read the doc once, top to bottom, as a teammate who knows the system but not this change. Note where you got lost
   or skimmed.
2. Run the review checklist. For each finding, give the location (heading and line), the problem, and a concrete fix:
   a rewrite, "delete", or "move to appendix".
3. Report:
   - A verdict in 3 lines or fewer: is it readable, the biggest problems, and roughly how long it would be after the
     cuts.
   - Findings in order: blocking (structure, missing problem or decision, undefined terms, content that doesn't belong),
     then cuts, then nits.
4. Technical correctness is out of scope, except claims that contradict the code: flag those.
5. Post comments on a PR only if the user asks; otherwise report to the user.
