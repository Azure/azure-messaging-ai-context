# Azure Messaging AI Context

Shared AI context files for Azure Messaging C repositories — copilot instructions, coding standards, skills, and helper scripts.

## Purpose

This repository decouples AI context (Copilot instructions, coding conventions, skills, scripts) from `c-build-tools` so that AI context updates don't trigger submodule propagation across all consuming repos.

## Structure

```
.github/
├── copilot-instructions.md          # Build infrastructure AI instructions
├── general_coding_instructions.md   # Coding standards and conventions
├── scripts/                         # Helper scripts
│   ├── parse_github_pr_comments.ps1
│   ├── parse_pr_threads.ps1
│   ├── run_coverage.ps1
│   └── watch_prs.ps1
└── skills/                          # Copilot skills
    ├── address-pr-comments/
    ├── apply-change-to-repo-hierarchy/
    ├── create-new-task/
    ├── extract-learnings/
    ├── run-coverage/
    └── watch-multiple-pr-status/
```

## Usage

Consuming repos add this as a git submodule:
```bash
git submodule add https://github.com/Azure/azure-messaging-ai-context.git deps/azure-messaging-ai-context
```

Then reference the files in `.github/copilot-instructions.md`:
```markdown
#file:../deps/azure-messaging-ai-context/.github/copilot-instructions.md
#file:../deps/azure-messaging-ai-context/.github/general_coding_instructions.md
```

## Review policy

Pull requests opened by the agent (`aiagentpool-mrbot[bot]`) need approvals from **two** distinct humans
with push access, on the pull request's current commit. A human-authored pull request already has two
people in the loop, the author and the approver; when the agent writes the change the first of those is
missing, and this restores it.

The requirement reports as the `mrbot/two-human-reviewers` status, which stays **pending** until the
approvals arrive rather than failing, because the pull request is waiting on a person rather than broken.