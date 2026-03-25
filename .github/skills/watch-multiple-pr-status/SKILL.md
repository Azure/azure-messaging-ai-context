---
name: watch-multiple-pr-status
description: Monitor the status of multiple GitHub and Azure DevOps PRs in a live dashboard. Use this skill when the user wants to watch, monitor, or track the status of multiple PRs at once. Triggers include "watch PRs", "monitor PRs", "PR status", "track PRs".
---

# Watch Multiple PR Status

Provide the user with a command to run the `watch_prs.ps1` script that displays a live-updating dashboard of PR statuses.

## When to invoke

- User asks to watch, monitor, or track multiple PRs
- After creating PRs across multiple repos and wanting to see their CI status
- When the user wants a dashboard view of PR check results

## What to do

1. Collect the PR URLs (GitHub and/or Azure DevOps)
2. Join them into a comma-separated string
3. Provide the user with the following command to copy-paste into a separate terminal:

```
pwsh <azure-messaging-ai-context-path>/.github/scripts/watch_prs.ps1 -PRs "<comma-separated PR URLs>"
```

Replace `<azure-messaging-ai-context-path>` with the actual local path to the azure-messaging-ai-context repo (or use `deps/azure-messaging-ai-context` from a consuming repo).

## Example

```
pwsh deps/azure-messaging-ai-context/.github/scripts/watch_prs.ps1 -PRs "https://github.com/Azure/c-logging/pull/306,https://github.com/Azure/ctest/pull/298,https://msazure.visualstudio.com/One/_git/zrpc/pullrequest/15088625"
```

## Supported PR URL formats

- GitHub: `https://github.com/{owner}/{repo}/pull/{number}`
- ADO: `https://msazure.visualstudio.com/One/_git/{repo}/pullrequest/{id}`
