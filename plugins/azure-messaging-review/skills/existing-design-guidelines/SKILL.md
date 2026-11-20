---
name: existing-design-guidelines
description: Rules for Azure Messaging design docs that describe how an existing part of the system works today (ED-CODE, ED-DEPTH). Loaded by Agency Review as a guideline source; the document-existing-design and review-design-doc skills use the same rules.
---

# Existing design guidelines

The rules are in `reference/existing_design_guidelines.md`: ED-CODE and ED-DEPTH. They apply only to a doc that
describes how an existing part of the system works, which has a `Verified against code at` line under its title; skip
a doc that proposes a change. They apply to new docs and to the text a pull request adds or rewrites in an existing
one. Don't flag text the pull request doesn't touch. The shape, link and diagram conventions (ED-SHAPE, ED-LINKS,
ED-DIAGRAMS) are in the existing-design-conventions skill, which the strict rules review checks; don't report them
here.

Check ED-CODE against the code: grep the identifiers the doc names and read the call sites of the flows it describes.
Rate findings as described in "Rating review findings" in the design doc guidelines. A claim that contradicts the code,
or unused code described as part of the running system, is Blocking (`blocking`).
