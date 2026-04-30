# Azure Messaging AI Coding Instructions

## General Coding Standards
**IMPORTANT**: All code changes must follow the comprehensive coding standards defined in #file:./general_coding_instructions.md This includes:
- Function naming conventions (snake_case, module prefixes, internal function patterns)
- Parameter validation rules and error handling patterns
- Variable naming and result variable conventions
- Header inclusion order and memory management requirements
- Requirements traceability system (SRS/Codes_SRS/Tests_SRS patterns)
- Async callback patterns and goto usage rules
- Indentation, formatting, and code structure guidelines

## Agent Skills
Agent Skills are available in this repository at `.github/skills/`. When relevant tasks are requested, load and follow the instructions from the appropriate `SKILL.md` file. Each subdirectory contains a skill with its own `SKILL.md` describing when and how to use it.

Skills location: #file:./.github/skills

## Git and Source Control Guidelines

### Commit Messages
- **MUST**: Use brief, concise commit descriptions (one line, under 72 characters when possible)
- **NEVER use multi-line commit messages** - always use a single-line description with no body text
- Focus on what changed, not how it changed
- Example: `Fix null pointer crash in block_storage_append_async`

### Target Branch
- **Default branch**: Always create PRs targeting `master` (not `main`)

### Pull Request Titles
- **AI-Generated PRs**: When creating a pull request, prepend `[MrBot]` to the title (e.g., `[MrBot] Fix null pointer crash in storage module`)

### Pull Request Descriptions
- Keep PR descriptions brief and to the point
- Summarize the change in 1-2 sentences
- Include relevant work item or issue references if applicable
- **Azure DevOps cross-references**: Use `!` prefix to link PRs (e.g., `!14810235`), not `#` which links to work items

### Starting Builds on GitHub PRs
- **Trigger builds**: After creating a PR, add a comment with `/azp run <pipeline-name>` to start the CI build
  - For **c-build-tools** repo: `/azp run Azure-C-Build-Tools-Gate`
  - For other repos: Check the repo's pipeline configuration or ask a team member for the correct pipeline name
- Builds do not start automatically; the comment is required

### Repository-Specific Tooling
- **Azure DevOps Repos**: Use the ADO MCP (Model Context Protocol) tools when available for repository operations (creating branches, PRs, managing work items)
- **GitHub Repos**: Use GitHub CLI (`gh`) for repository operations (creating PRs, managing issues, etc.)

## PowerShell Terminal Commands

When you need to run PowerShell in the terminal, ALWAYS emit a single line in this shape:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -InputFormat None -ExecutionPolicy Bypass -Command "& { $ErrorActionPreference='Stop'; <STATEMENT1>; <STATEMENT2>; <STATEMENT3>; }"
```

**Rules:**
- Use `;` between statements; never use backticks for continuation.
- Prefer single quotes inside the script block; escape only when necessary.
- If CLI args contain special characters, use `--%` immediately after the command name.

## General Terminal Command Rules

**ALL terminal commands MUST be single-line.** Multi-line commands cause the terminal to hang waiting for input.

- **Never embed literal newlines** in command arguments (e.g., `--body` or `--message` flags)
- **Use semicolons** to chain multiple commands: `cmd1; cmd2; cmd3`
- **For long strings**, keep them on one line or use variables/files instead of inline content
- **Test mentally**: If the command would show a `>>` continuation prompt, rewrite it as single-line

### Terminal Troubleshooting
- **Stuck Terminal Detection**: If git operations (commit, push, pull) appear to not succeed or produce no/partial output, the terminal may be stuck waiting for input
- **Reset Stuck Terminals**: When a terminal appears stuck, reset it and retry the operation
- **Common Causes**: Multi-line strings in commit messages, interactive prompts (credentials, merge conflicts), or commands waiting for stdin
