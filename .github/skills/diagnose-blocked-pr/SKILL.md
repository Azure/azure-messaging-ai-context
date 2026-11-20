---
name: diagnose-blocked-pr
description: Find out why an Azure DevOps PR cannot complete and unblock it. Use this skill when tracking a PR, waiting for it to merge, re-running or re-evaluating a check, or when a PR is stuck on approvals, statuses or policies. Triggers include "PR is blocked", "PR won't complete", "waiting for ownership enforcement", "owner approval is stale", "status not updating", "re-evaluate", "requeue", "why can't I merge".
---

# Diagnose a blocked PR

A PR that cannot complete is usually waiting on a blocking policy. Find which policy, what it waits on, and whether
that thing is really unmet or just not refreshed.

## When to invoke

- The user is tracking a PR, waiting for it to merge, or asking why it cannot complete
- A check needs re-running or re-evaluating
- Approvals are in place but the PR still shows a blocking status (for example "Owner approval is stale" from
  Ownership Enforcer, or "must be approved by at least 2 human reviewer(s) after the last commit" from review-checker)

## Step 1: Diagnose (read-only)

Collect the facts before changing anything. Replace `<org>`, `<project>`, `<repo>` and `<id>` from the PR URL; the
`--org` value is `https://dev.azure.com/<org>`.

1. Blocking policies that are not approved, and the status each one waits on:
   ```
   az repos pr policy list --org https://dev.azure.com/<org> --id <id> --query "[?configuration.isBlocking && status!='approved'].{policy:configuration.type.displayName,status:status,statusId:context.latestStatusId,build:context.buildId}" -o table
   ```
2. The PR statuses: their count, and the `context.name`, `description` and `updatedDate` of each `statusId` from 1:
   ```
   az devops invoke --org https://dev.azure.com/<org> --area git --resource pullRequestStatuses --route-parameters project=<project> repositoryId=<repo> pullRequestId=<id> --api-version 7.1 -o json
   ```
3. The last push, and the votes after it (threads whose `properties.CodeReviewThreadType` is `VoteUpdate`):
   ```
   az devops invoke --org https://dev.azure.com/<org> --area git --resource pullRequestIterations --route-parameters project=<project> repositoryId=<repo> pullRequestId=<id> --api-version 7.1 --query "value[-1]" -o json
   az devops invoke --org https://dev.azure.com/<org> --area git --resource pullRequestThreads --route-parameters project=<project> repositoryId=<repo> pullRequestId=<id> --api-version 7.1 -o json
   ```
4. Ownership Enforcer's own latest evaluation, kept in the `OneReviewPolicyPilot` PR property even when its status is
   not refreshed. Its `$value` is JSON: read `LastIterationApproved` and, per owner path, `IsApproved` and the owners'
   `IsStale`:
   ```
   az devops invoke --org https://dev.azure.com/<org> --area git --resource pullRequestProperties --route-parameters project=<project> repositoryId=<repo> pullRequestId=<id> --api-version 7.1-preview --query "value.OneReviewPolicyPilot" -o json
   ```

A blocking status is **stale** when it was posted before the latest vote that should satisfy it.

## Step 2: Act on what you found

- **Build policy failed or expired**: requeue the build. A failed build needs its failure investigated first.
- **A required reviewer or minimum reviewer count is missing**: ask for the missing approval. The author's own vote
  and votes cast before the last push may not count.
- **A blocking status is stale while its requirement is met** (for example Ownership Enforcer's evaluation shows
  `LastIterationApproved` true and the owner not stale): the bot did not post a new status.
  1. Re-trigger it: "Re-evaluate" on the Owners tab for Ownership Enforcer, or a reviewer resets their vote and
     approves again, which re-runs most bots.
  2. If the status still does not change, check the status count.
- **The PR has 10,000 statuses**: Azure DevOps does not accept new statuses past 10,000, so every bot is silently
  stuck and re-evaluating does nothing. Free up room by deleting old statuses of a context that no policy waits on,
  usually `codecoverage`, `ComponentGovernance` or `LicenseCheck`, which post on every build:
  1. Get the user's explicit approval first. Deleting statuses cannot be undone.
  2. Pick the oldest statuses of that context, excluding every `statusId` from Step 1 and the newest status of the
     context. Delete one first to confirm permission, then the rest in batches of up to 200: write a JSON array of
     `{"op": "remove", "path": "/<statusId>"}` entries to a file and send it:
     ```
     az rest --method patch --resource 499b84ac-1321-427f-aa17-267ca6975798 --uri "https://dev.azure.com/<org>/<project>/_apis/git/repositories/<repo>/pullRequests/<id>/statuses?api-version=7.1" --headers "Content-Type=application/json-patch+json" --body "@<file>"
     ```
  3. Re-trigger the stuck bots as above and collect the facts again.
- **Nothing above explains it**: escalate to the bot's owner (the Owners tab links Ownership Enforcer support) with
  the PR URL, the stuck status ID and date, and the `CorrelationId` from the `OneReviewPolicyPilot` property.

## Do not

- Push a commit just to re-run checks: it makes every approval stale again.
- Delete statuses without the user's approval, or delete a status a policy references.
- Keep asking a bot or assistant that repeats the same instructions; collect the facts and act on them.
