---
name: review-history-decisions
description: Builds the history decisions that `agency review publish` asks for, so findings that existing pull request threads already report are not posted again. Used by the strict-rules-review agent.
---

# Review history decisions

`agency review publish` compares new findings with the pull request's existing threads. When a thread may already
report a finding, publish returns a history request and waits for decisions. Publish rejects the whole decisions file
if any comparison is missing or malformed, and then posts every finding again, so build it with
`history_decisions.py` in this skill's folder (Python 3) instead of writing it by hand:

1. Run `history_decisions.py candidates <run>/history-request.json` and read its output: the new findings and the
   existing threads of each file.
2. For each finding, pick the threads that report the same problem at the same place: the same rule, or the same
   concern from another review, on the same text. A thread on another occurrence of the rule is not a match. A Won't
   Fix or By Design thread that rejected the same rule for the same kind of text is a match, even on another file.
3. Write the matches to `<run>/history-matches.json` as a JSON list of `{"findingId", "threadId", "reason"}`, and
   `[]` when nothing matches.
4. Run `history_decisions.py write <run>/history-request.json <run>/history-matches.json
   <run>/history-decisions.json`. It compares every other pair as distinct and fails on a finding or thread that is
   not in the request. Both commands fail on a request schema other than 2.0, which means the CLI changed and the
   script needs updating.
5. Pass `--history-decisions <run>/history-decisions.json` to the next publish.
