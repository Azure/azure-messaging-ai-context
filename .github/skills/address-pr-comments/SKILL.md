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

1. **Ask for approval** - Confirm with the user that all comments have been addressed satisfactorily
2. **Push changes** - Push all local commits to the remote branch using `git push`
3. **Reply to comments and mark as resolved/fixed**:
   - **Azure DevOps PRs**: Use ADO MCP tools
     - `ado-repo_reply_to_comment` to reply to each thread
     - `ado-repo_update_pull_request_thread` with status "Fixed" or "Resolved" (NEVER use "Closed" - the human reviewer who made the comment is expected to mark comments "Closed" after reviewing the changes)
   - **GitHub PRs**: Use GitHub CLI
     - `gh pr review` or `gh api` to reply to review comments
   - **On failure**: If updating a thread fails (e.g., `Error updating pull request thread`), retry the operation. If it continues to fail, track it for the summary.
4. **Summarize results** - Provide a summary to the user including:
   - List of all comments that were addressed
   - Any comments that failed to update (with thread IDs) so the user can manually resolve them
   - Any comments that were skipped or need clarification

## Code Comment Policy

When applying a fix in response to a review comment, **do not add a comment to the source code that exists only to narrate the PR iteration**. The reviewer's feedback, the prior state of the diff, and the reasoning for the change all live in git history and the PR thread — they should not bleed into the committed source.

### The test

Before committing any new or modified comment, apply this check:

> Read the final code without any knowledge of this PR. Does the comment still describe something that is **non-obvious about the code itself** (an invariant, an edge case, a subtle ordering requirement, a non-trivial "why")? If the comment only makes sense when you also know what the previous version of the diff looked like, or what a reviewer asked for, **delete it**.

If you are unsure, consult the rubber-duck agent and ask it to evaluate the comment under that test.

### Comments to AVOID adding

These are pure PR-iteration narration and **must not** be committed:

- `// Use accessor function instead of touching the field directly (per review).`
- `// Reviewer requested we validate the input here.`
- `// Switched from the previous approach to keep the lock scope smaller.`
- `// This block was reordered to handle the empty case first.`
- `// Renamed from old_name; see PR feedback.`
- `// Note: the earlier version assumed X, which is no longer true.`
- Any comment whose subject is "this change", "this fix", "the previous code", "the old version", "the reviewer", "the suggestion", etc.

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

Prefer **no comment** over a narration comment. A clean diff with no chatter is almost always better than one with explanatory clutter that will be confusing to the next reader.

## Key Principles

- Address comments one at a time to keep changes focused and reviewable
- Always build and test after each change to catch issues early
- Commit after each comment to maintain clear history
- Wait for user approval before pushing to allow for review of changes
- Ask the user if they would like you to reply to comments. If yes, reply with specific details about how they were addressed
- Use the correct platform tools (ADO MCP for Azure DevOps, GitHub MCP/CLI for GitHub)

## AI Reply Format

When posting replies to PR comments, prefix each reply with **"🤖 MrBot:"** to clearly indicate the response was generated by AI. This helps reviewers distinguish AI-generated replies from human responses.

Example reply format:
```
🤖 MrBot: Fixed by updating the null check before accessing the pointer. See commit abc1234.
```
