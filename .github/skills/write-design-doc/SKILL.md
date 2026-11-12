---
name: write-design-doc
description: Write or revise a design doc (RFC, new component, or change to an existing system). Use for any change to a design doc, design, RFC or proposal, from a first draft to small edits, including addressing review comments on one.
---

# Write a design doc

Follow [design_doc_guidelines.md](design_doc_guidelines.md).

## Write a doc

1. **Check the premise.** Read the code and docs the change touches, and any data you can get (metrics, logs). If the
   request rests on a wrong assumption, tell the user before writing.
2. **Settle the decisions.** List the decisions that shape the design: approach, which component owns what, formats,
   failure behavior. Ask the user about the ones the code doesn't settle, one at a time, each with your
   recommendation. If you can't ask, pick one and list it under Open questions.
3. **Outline.** Pick the doc type and whether it is a new doc, an edit to an existing doc, or both. Write the headings
   with one line each before writing prose.
4. **Draft.**
5. **Self-review.** Read the draft top to bottom as a teammate who hasn't seen it, run the review checklist, and fix
   every finding.
6. **Cut.** Shorten or delete every paragraph that doesn't change what the reader understands, then rerun the lint.
7. **Report** the path, the doc type and the decisions the user should double-check, in 5 lines or fewer, then the
   attribution line.

## Review comments

Follow "Revising after review" in the guidelines. When done, reread the whole doc for text your edits made stale or
contradictory, run the lint and fix only findings in lines you changed. Tell the user how many words the doc gained or
lost, and list any other problems you saw.

## Attribution

End the description of the doc's PR with this line, updated on every pass. If you don't edit the PR, give the line to
the user to add.

```
Design doc written with write-design-doc (azure-messaging-ai-context@<commit>) by <model>.
```

- `<commit>`: `git log -1 --format=%h -- .` run in this skill's folder, or `unversioned` if that prints nothing.
- `<model>`: the model name your instructions give. Add the reasoning effort or context window only if your instructions
  state it; never guess.
