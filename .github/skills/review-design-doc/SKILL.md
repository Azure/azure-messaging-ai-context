---
name: review-design-doc
description: Review a design doc or RFC for readability, structure and level of detail. Use when asked to review a design doc, design PR or RFC, or to check whether a design doc is easy to read.
---

# Review a design doc

Use [design_doc_guidelines.md](../write-design-doc/design_doc_guidelines.md).

1. Read the doc once, top to bottom, as a teammate who knows the system but not this change. Note where you got lost,
   had to reread, or skimmed.
2. Run the review checklist. Keep a finding only if it costs the reader: confusion, wasted reading, or guessing at
   behavior. A difference from the guidelines that costs the reader nothing (for example, an older doc without a
   status line) is a nit. For each finding, give the location (heading and line), the problem, and a concrete fix: a
   rewrite, "delete", or "move to appendix".
3. Report:
   - A verdict in 3 lines or fewer: is it readable, the biggest problems, and roughly how long it would be after the
     cuts.
   - Findings ranked by cost to the reader: blocking (missing problem or decision, undefined terms, wrong structure,
     content that doesn't belong), then cuts, then nits. Report the lint output as one nit.
   - If the doc reads well, say so; a good doc gets few findings.
4. Technical correctness is out of scope, except claims that contradict the code: flag those.
5. Post comments on a PR only if the user asks; otherwise report to the user.
