---
name: write-design-doc
description: Write or revise a design doc (RFC, new component, or change to an existing system). Use when asked to write, draft, update or rewrite a design doc, design, RFC or proposal, or to address review comments on a design doc.
---

# Write a design doc

Follow [design_doc_guidelines.md](design_doc_guidelines.md).

## Write a doc

1. **Check the premise.** Read the code and docs the change touches, and any data you can get (metrics, logs). If the
   request rests on a wrong assumption, tell the user before writing.
2. **Settle the decisions.** List the decisions that shape the design: approach, which component owns what, formats,
   failure behavior. Ask the user about the ones the code doesn't settle, one at a time, each with your
   recommendation. If you can't ask, pick one and list it under Open questions.
3. **Outline.** Pick the doc type (for a change, also the existing doc to link from) and write the headings with one
   line each before writing prose.
4. **Draft.**
5. **Self-review.** Read the draft top to bottom as a teammate who hasn't seen it, run the review checklist, and fix
   every finding.
6. **Cut.** Shorten or delete every paragraph that doesn't change what the reader understands, then rerun the lint.
7. **Report** the path, the doc type and the decisions the user should double-check, in 5 lines or fewer.

## Review comments

Follow "Revising after review" in the guidelines. When done, run steps 5 and 6 on the whole doc and tell the user how
many words the doc gained or lost.
