#!/usr/bin/env python3
"""Builds the history decisions that `agency review publish` asks for.

`agency review publish` returns a history request when existing pull request
threads may already report a new finding. The decisions must compare every
candidate finding with every candidate thread of its group exactly once, or
publish rejects all of them and posts every finding again. This script writes
that structure, so the reviewer only decides which threads report the same
problem.

  history_decisions.py candidates <history-request.json>
      Prints each group's findings and threads as compact JSON for review.

  history_decisions.py write <history-request.json> <matches.json> <out.json>
      Writes the decisions. matches.json is a JSON list of
      {"findingId": ..., "threadId": ..., "reason": ...} for each thread that
      reports the same problem as the finding; every other pair is distinct.
"""

import html
import json
import re
import sys

GUIDELINE = re.compile(r"Guidelines?:\s*`([^`]+)`")
MARKUP = re.compile(r"<!--.*?-->|<[^>]+>", re.S)
BADGE = re.compile(r"^Iteration #\d+\s*")
FOOTER = re.compile(r"\s*(---\s*)?\*\*Was this finding helpful\?\*\*.*$", re.S)
DISMISSED = ("wontFix", "byDesign")


def load(path):
    with open(path, encoding="utf-8-sig") as stream:
        return json.load(stream)


def plain(content, limit=400):
    text = " ".join(html.unescape(MARKUP.sub(" ", content)).split())
    text = FOOTER.sub("", BADGE.sub("", text))
    return text[:limit]


def thread_rule(thread):
    match = GUIDELINE.search(thread["comments"][0]["content"])
    return match.group(1) if match else None


def candidates(request):
    groups = []
    for group in request["groups"]:
        groups.append({
            "file": group["file"],
            "findings": [{
                "id": finding["id"],
                "rule": finding.get("guidelineId"),
                "lines": [finding["anchor"]["startLine"], finding["anchor"]["endLine"]],
                "message": plain(finding["message"]),
            } for finding in group["findings"]],
            "threads": [{
                "id": thread["id"],
                "file": thread["file"],
                "status": thread["status"],
                "rule": thread_rule(thread),
                "text": plain(thread["comments"][0]["content"]),
            } for thread in group["threads"]],
        })
    return groups


def write(request, matches):
    groups = {}
    for group in request["groups"]:
        for finding in group["findings"]:
            groups[finding["id"]] = group
    matched = {}
    for match in matches:
        finding_id, thread_id = match["findingId"], int(match["threadId"])
        group = groups.get(finding_id)
        if group is None:
            raise ValueError(f"finding {finding_id} is not in the history request")
        thread = next((t for t in group["threads"] if t["id"] == thread_id), None)
        if thread is None:
            raise ValueError(f"thread {thread_id} is not a candidate for {finding_id}")
        if thread["file"] != group["file"] and thread["status"] not in DISMISSED:
            raise ValueError(f"thread {thread_id} is on another file than {finding_id}")
        matched[(finding_id, thread_id)] = match.get("reason") or "Reports the same problem."
    decisions = []
    for group in request["groups"]:
        for finding in group["findings"]:
            comparisons = []
            for thread in group["threads"]:
                comparison = {
                    "threadId": thread["id"],
                    "commentIds": [comment["id"] for comment in thread["comments"]],
                }
                reason = matched.get((finding["id"], thread["id"]))
                if reason is None:
                    same_rule = thread_rule(thread) == finding.get("guidelineId")
                    comparison["relationship"] = "distinct"
                    comparison["reason"] = (
                        "Same rule, different occurrence." if same_rule else "Different problem."
                    )
                elif thread["file"] != group["file"]:
                    comparison["relationship"] = "covered-by-dismissal"
                    comparison["reason"] = reason
                    comparison["dismissalApplicable"] = True
                else:
                    comparison["relationship"] = "same-issue"
                    comparison["reason"] = reason
                    if thread["status"] in DISMISSED:
                        comparison["dismissalApplicable"] = True
                comparisons.append(comparison)
            decisions.append({
                "findingId": finding["id"],
                "complete": True,
                "reason": "Compared with every candidate thread.",
                "comparisons": comparisons,
            })
    return {
        "schemaVersion": request["schemaVersion"],
        "bindings": request["bindings"],
        "decisions": decisions,
    }


def main(argv):
    if len(argv) == 3 and argv[1] == "candidates":
        json.dump(candidates(load(argv[2])), sys.stdout, indent=1)
        print()
        return 0
    if len(argv) == 5 and argv[1] == "write":
        document = write(load(argv[2]), load(argv[3]))
        with open(argv[4], "w", encoding="utf-8") as stream:
            json.dump(document, stream, indent=1)
        same = sum(
            1 for d in document["decisions"] for c in d["comparisons"]
            if c["relationship"] != "distinct"
        )
        print(json.dumps({
            "findings": len(document["decisions"]),
            "comparisons": sum(len(d["comparisons"]) for d in document["decisions"]),
            "matches": same,
        }))
        return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
