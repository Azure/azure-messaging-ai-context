---
name: document-existing-design
description: Document how an existing system, layer, subsystem or module works today, as a short design doc in a linked tree of docs. Use to document an undocumented design, rewrite or refresh a stale design doc, or split a design doc into parent and child docs. For proposing a change, use write-design-doc.
---

# Document an existing design

Follow [existing_design_guidelines.md](../../../plugins/azure-messaging-review/skills/existing-design-guidelines/reference/existing_design_guidelines.md),
[existing_design_conventions.md](../../../plugins/azure-messaging-review/skills/existing-design-conventions/reference/existing_design_conventions.md),
and DD-ORDER, DD-CONTENT, DD-WORDS and DD-FORMAT in
[design_doc_conventions.md](../../../plugins/azure-messaging-review/skills/design-doc-conventions/reference/design_doc_conventions.md).

1. **Scope.** Find the part the user asked about, the code it covers, its parent's doc if any, and every doc that
   overlaps it (search the docs for its module names and follow links).
2. **Read the code.** Start from the part's callers and follow the calls down. Note which modules each main flow
   touches, which run only in some roles or modes, and which are written but not used.
3. **Check the existing docs.** For each overlapping doc, note what is current, what the code contradicts, and what
   was never built.
4. **Propose the tree and the concepts.** List the part's pieces that deserve their own doc, as deep as you can see,
   marking which have a doc today and which are gaps. Propose what to do with each overlapping doc: rewrite it in
   place if it covers one doc's scope; otherwise merge its current content into the docs it overlaps and delete it.
   List the core concepts the doc will explain, marking those that need more than a sentence or two. Before drafting,
   ask the user one question at a time: which docs to write, rewrite, merge or delete now, then which concepts to
   include or explain in more depth (always ask this one, even after the user answers the first), then about any split
   the code doesn't settle. If you can't ask, write only the requested doc and leave every other doc as it is.
5. **Draft** the docs the user chose, top-down. Change other docs only to fix links to the docs you wrote or deleted.
6. **Verify with a fresh reader.** Give each doc to a sub-agent that has none of your context (a different model
   family if you can choose one). Ask it to list every claim the doc makes about the code, check each against the
   code, and report the claims the code contradicts or doesn't support, with the evidence. Claims about which module
   creates or owns another, which thread runs what, what happens on a failure, formats, what is built but unused, and
   which callers or cases a behavior covers are the ones drafts most often get wrong. Check each reported claim
   yourself, fix or cut it, and repeat until a pass reports nothing wrong, at most two passes. If you can't start a
   sub-agent, do the same check yourself as a separate pass, claim by claim.
7. **Check.** Run `../write-design-doc/lint_design_doc.ps1 -ExistingDesign` on each doc you wrote and fix every
   finding. Read each doc top to bottom as a teammate who knows the system but not this part, and cut what doesn't help
   them.
8. **Report** in 10 lines or fewer: the tree (written, existing, proposed), the files rewritten, merged or deleted, the
   changes you proposed but didn't make, and the wrong statements you found in docs you didn't change. Then give the
   attribution line.

## Review comments

Follow "Revising after review" in
[design_doc_guidelines.md](../../../plugins/azure-messaging-review/skills/design-doc-guidelines/reference/design_doc_guidelines.md),
check every changed claim against the code, update the `Verified against code at` line if you did, then run the lint
and fix only findings in lines you changed.

## Attribution

End the description of the doc's PR with this line, updated on every pass. If you don't edit the PR, give the line to
the user to add.

```
Design doc written with document-existing-design (azure-messaging-ai-context@<commit>) by <model>.
```

- `<commit>`: `git log -1 --format=%h -- . '../../../plugins/azure-messaging-review/skills/*design*'` run in this
  skill's folder, or `unversioned` if that prints nothing.
- `<model>`: the model name your instructions give. Add the reasoning effort or context window only if your
  instructions state it; never guess.
