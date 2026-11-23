---
name: design-doc-guidelines
description: Design rules for Azure Messaging design docs and RFCs (DD-TYPE, DD-DESIGN, DD-DEPTH), and how to rate review findings against them. Loaded by Agency Review as a guideline source; the write-design-doc and review-design-doc skills use the same rules.
---

# Design doc guidelines

The rules are in `reference/design_doc_guidelines.md`: DD-TYPE, DD-DESIGN and DD-DEPTH. They apply to new design docs
and to the text a pull request adds or rewrites in an existing one. Don't flag text the pull request doesn't touch.
Skip a doc that describes how an existing part of the system works (it has a `Verified against code at` line under its
title); the existing-design-guidelines skill covers it.
The writing conventions (DD-OUTLINE, DD-ORDER, DD-CONTENT, DD-WORDS, DD-FORMAT) are in the design-doc-conventions
skill, which the strict rules review checks; don't report them here.

Rate findings as described in "Rating review findings" in the rules file, and map the rating to the Agency Review
severity as follows: Blocking is `blocking`, Question and Cut are `suggestion`, and Nit is `info`. A
design doc has no runtime failure path, so a Blocking finding is one that leaves the reader unable to build the
design correctly: a design bug or gap, a claim that contradicts the code, or an undecided behavior. Each rule ends
with a "Why:" line; a violation has that consequence for the reader, so a violation that passes the filter in
"Rating review findings" is at least a Nit (`info`).

The "Review checklist" in the rules file is for the review-design-doc skill; don't run its lint script.