---
name: address-pr-comments
description: Guide for addressing PR review comments iteratively. Use this when asked to address, fix, or resolve comments on a pull request (Azure DevOps or GitHub).
---

To address PR review comments, follow this process:

## Phase 1: Fetch PR Comments

Use the appropriate tool based on the PR platform:

- **Azure DevOps PRs**: Use ADO MCP tools
  - `ado-repo_list_pull_request_threads` to get comment threads
  - `ado-repo_list_pull_request_thread_comments` for thread details
- **GitHub PRs**: Use GitHub MCP tools
  - `github-mcp-server-pull_request_read` with method `get_review_comments`

## Phase 2: Process Each Comment

For each active comment in the PR:

1. **Mark the comment as pending** - Set the thread status to "Pending" to indicate it is being processed
   - **Azure DevOps PRs**: Use `ado-repo_update_pull_request_thread` with status "Pending"
2. **Read the comment** - Understand what change is being requested
3. **Address the comment** - Make the necessary code/documentation changes
   - If anything is unclear, ambiguous, or you get stuck, reply to that specific comment asking for clarification from the reviewer before proceeding
   - **Do NOT leave PR-narration comments in the code** - see [Code Comment Policy](#code-comment-policy) below
4. **Build and run unit tests** - Verify the change doesn't break anything
   - Build the affected module's unit tests
   - Run the tests and ensure they pass
5. **Commit locally** - Create a focused commit for this specific change
   - Use a descriptive commit message that references the comment

## Phase 3: Finalize

After all comments have been addressed:

1. **Pause only for ambiguity**:
   - If **any** review comment was unclear or ambiguous (something a reasonable person could interpret in more than one way, or where you had to guess at the reviewer's intent), stop and ask the user how to proceed before pushing or replying. List each ambiguous comment and the interpretation you would otherwise apply.
   - If **none** of the comments were ambiguous, proceed automatically through the remaining steps (push, refresh description, reply, resolve) without asking for approval.
2. **Push changes** - Push all local commits to the remote branch using `git push`
3. **Refresh the PR description** - PR descriptions drift across review iterations as the change evolves. After pushing, re-read the current description and make sure it still accurately describes the *final* state of the PR — what it does now, not what the first draft did and not the story of how it got here. Apply the same principle as the [Code Comment Policy](#code-comment-policy): the description should make sense to someone who has never seen the prior iterations or the review thread. Concrete checks:
   - Does any wording refer to behavior, files, types, or APIs that no longer exist in the current diff? Update or remove.
   - Does the description still narrate "v1 did X, then reviewer suggested Y, so v2 does Z"? Rewrite as a description of Z only.
   - Have new files, scenarios, or behavior changes been added that the description never mentioned? Add them.
   - If the description is still accurate, leave it alone — do not edit just to mark the iteration.
   - **GitHub PRs**: Write the new description to a file and use `gh pr edit <pr> --body-file <file>`. **Never** pass a multi-line description as an inline `--body` argument — PowerShell will mangle newlines, backticks, and `$` characters.
   - **Azure DevOps PRs**: Write the description into a JSON body file and PATCH it via `az rest` (see the repo-level ADO description rule for the exact pattern). **Never** pass the description as an inline CLI argument to `az repos pr update`.
4. **Reply to comments and mark as resolved/fixed**:
   - **Azure DevOps PRs**: Use ADO MCP tools
     - `ado-repo_reply_to_comment` to reply to each thread
     - `ado-repo_update_pull_request_thread` with status "Fixed" or "Resolved" (NEVER use "Closed" - the human reviewer who made the comment is expected to mark comments "Closed" after reviewing the changes)
   - **GitHub PRs**: Use GitHub CLI
     - `gh pr review` or `gh api` to reply to review comments
   - **On failure**: If updating a thread fails (e.g., `Error updating pull request thread`), retry the operation. If it continues to fail, track it for the summary.
5. **Summarize results** - Provide a summary to the user including:
   - List of all comments that were addressed
   - Any comments that failed to update (with thread IDs) so the user can manually resolve them
   - Any comments that were skipped or need clarification

## Code Comment Policy

When applying a fix in response to a review comment, **do not add a comment to the source code that exists only to narrate the PR iteration**. The reviewer's feedback, the prior state of the diff, and the reasoning for the change all live in git history and the PR thread — they should not bleed into the committed source.

### The test

Before committing any new or modified comment, apply this check:

> Read the final code without any knowledge of this PR. Does the comment still describe something that is **non-obvious about the code itself** (an invariant, an edge case, a subtle ordering requirement, a non-trivial "why")? If the comment only makes sense when you also know what the previous version of the diff looked like, or what a reviewer asked for, **delete it**.

If you are unsure, consult the rubber-duck agent and ask it to evaluate the comment under that test.

### Common pitfalls — comments to AVOID adding

Each rule below is a smell distilled from real reviewer pushback. If a comment you are about to write fits any of them, delete it before committing.

- **Narrating the PR's purpose inside a config / manifest / build file.**  E.g. `# Pinned to <X> for <feature Y> (see PBI 12345)` on a dependency pin, or `# Bumped to <ver> because <bug>`. The pin / version *is* the constraint; the *why* belongs in the commit message and work item, not in the manifest.
- **Long "this is the production default because (ticket nnn)" justifications next to a literal value.**  E.g. `// Production default after ICM 12345 fix. Setting this explicitly so the test is self-documenting and decoupled from the helper's default. ... = 60000;`. If a reader ever needs the ticket they can `git blame` the line; the comment as written is mostly chatter.
- **Comments that justify the *absence* of code.**  E.g. `# NOTE: <step X> is intentionally NOT used here to avoid <transient failure Y> (see AB#12345).`. These age badly — once someone adds `<step X>` later for an unrelated reason, the comment quietly becomes a lie.
- **Historical narration about an authoring choice.**  E.g. `// Kept as a free function for testability`, `// Moved here to keep <other thing> smaller`, `// Extracted from <other_fn> so the lock scope is tighter`. Whether something is a free function vs. a method, or where it lives, is visible in the code; *why the author shaped it that way during a particular PR iteration* is not interesting to the next reader.
- **Comments that restate the immediately adjacent line.**  E.g. `# Run the .NET unit tests` above a YAML task already named `🧪 VsTest - Foo.UnitTests`, or `// increment counter` above `counter += 1;`. If the next line makes the comment redundant, the comment is noise.
- **Comments whose subject is the PR itself.**  Any comment that talks about *"this change"*, *"this fix"*, *"the previous code"*, *"the old version"*, *"the reviewer"*, *"per review"*, *"the suggestion"*, *"we used to…"*, *"originally we…"* is a PR-thread artifact masquerading as a code comment. Delete it.

### Comments that ARE appropriate

Add or keep a comment **only if you would have written the same comment when first authoring the code, with no PR involved**. Typical legitimate cases:

- A non-obvious invariant or precondition the caller must satisfy.
- An edge case that is easy to misread or regress (e.g. "len can be 0; mmap rejects zero-length maps, so short-circuit here").
- A non-trivial reason for choosing one approach over an obvious-looking alternative, where the alternative is a real footgun (not just "we used to do X").
- Required documentation (e.g. doc comments on public APIs, SRS/requirement tags, SAFETY blocks on `unsafe` Rust).
- A comment the user (or the reviewer) explicitly asked you to add.

### When the reviewer asks for a comment

If a reviewer literally says "please add a comment explaining X", add a comment that explains **X itself** — not "added per review". Write it as if you were documenting the code from scratch.

### When in doubt

Prefer **no comment** over a narration comment, and prefer **a short comment** over a long one. A clean diff with no chatter is almost always better than one with explanatory clutter that will be confusing — or just plain stale — to the next reader. If you can imagine a reviewer reacting with *"comment not needed"*, *"too verbose"*, *"self-explanatory"*, *"doesn't belong here"*, or *"don't do that"*, the comment should never have been written in the first place.

## Key Principles

- Address comments one at a time to keep changes focused and reviewable
- Always build and test after each change to catch issues early
- Commit after each comment to maintain clear history
- Only pause for the user when a review comment was ambiguous; otherwise push, reply, and resolve automatically once all comments are addressed
- Treat the PR description like a code comment: it should describe the **final** state of the change, not narrate the iteration history. Refresh it after every push if the change has drifted from what the description says.
- Reply to comments automatically with specific details about how they were addressed (unless an ambiguity pause is in effect)
- Use the correct platform tools (ADO MCP for Azure DevOps, GitHub MCP/CLI for GitHub)

## AI Reply Format

When posting replies to PR comments, prefix each reply with **"🤖 MrBot:"** to clearly indicate the response was generated by AI. This helps reviewers distinguish AI-generated replies from human responses.

Example reply format:
```
🤖 MrBot: Fixed by updating the null check before accessing the pointer. See commit abc1234.
```
