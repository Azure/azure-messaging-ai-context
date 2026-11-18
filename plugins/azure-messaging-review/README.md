# azure-messaging-review

Review rules for the Azure Messaging C repositories, and the agent that enforces
the strict ones. Two reviews run on every pull request in the repositories that
opt in, and both post findings as pull request threads:

- **Agency Review** ([docs](https://eng.ms/docs/agency/partners/agencyreview/agency-review))
  runs its general review plus the rules that need judgment, such as whether a
  design is complete and matches the code. Its critic re-checks every finding
  against the code and drops the ones it judges immaterial or wrong. The critic
  can't be configured.
- **The strict rules review** (`agents/strict-rules-review.agent.md`) runs the
  convention rules. It uses the same `agency review` CLI pipeline with every
  finding accepted, so every violation is posted, including wording and
  formatting ones that the critic would drop.

## Layout

```
plugins/azure-messaging-review/
├── plugin.json                    # Plugin manifest
├── agency.json                    # Agency metadata (pluginId, engines)
├── agents/
│   └── strict-rules-review.agent.md
└── skills/                        # One skill per rule family
    ├── ctest-guidelines/
    │   ├── SKILL.md               # Context for reviewers
    │   └── reference/
    │       └── parameterized-tests.guidelines.md
    ├── design-doc-conventions/
    │   ├── SKILL.md
    │   └── reference/
    │       └── design_doc_conventions.md
    └── design-doc-guidelines/
        ├── SKILL.md
        └── reference/
            └── design_doc_guidelines.md
```

Each skill is one family of rules. Its `SKILL.md` gives reviewers background,
and each file in `reference/` holds rules in the
[guideline format](https://eng.ms/docs/agency/partners/agencyreview/agency-review#guidelines):
a frontmatter `applyTo` glob that limits which changed files the file applies
to, then one section per rule with a stable ID.

## Rules

| Skill                    | Rules                                                           | Review        |
|--------------------------|-----------------------------------------------------------------|---------------|
| `ctest-guidelines`       | `CTEST-PARAM-001` to `CTEST-PARAM-003`                          | Strict rules  |
| `design-doc-conventions` | `DD-OUTLINE`, `DD-ORDER`, `DD-CONTENT`, `DD-WORDS`, `DD-FORMAT` | Strict rules  |
| `design-doc-guidelines`  | `DD-TYPE`, `DD-DESIGN`, `DD-DEPTH`                              | Agency Review |

The ctest rules apply to `**/tests/**/*.c` and `**/tests/**/*.cpp`, and the
design doc rules to `**/doc/design/**/*.md`, `**/*design*.md` and
`**/*Design*.md`.

The design doc rules and conventions are also what the
[write-design-doc](../../.github/skills/write-design-doc/SKILL.md) and
[review-design-doc](../../.github/skills/review-design-doc/SKILL.md) skills
follow, so a change to a rule changes those skills too.

## Adding a rule

- Add a rule to an existing file in a skill's `reference/` folder, or add a new
  file there with its own `applyTo`.
- Pick the review by the rule:
  - A rule whose every violation must be fixed or resolved by a person, such
    as a naming, formatting, structure or traceability convention, goes in a
    skill of the strict rules review.
  - A rule that needs judgment against the code, where a reviewer can be wrong,
    goes in a skill of Agency Review, whose critic filters out wrong findings.
- Add a new skill for a new family of rules, then add it to the
  `[[review.strict.guidelines]]` or `[[review.default.guidelines]]` list of the
  repositories that should use it. Never list a skill in both, or both reviews
  post the same findings.
- Give each rule a new, unique ID and never reuse a retired one.
- End each rule with a `Why:` line that states the consequence of a violation.
  Reviewers quote it as the impact of a finding.

## Using the plugin

Azure DevOps repositories load the plugin from the Azure DevOps mirror of this
repository,
[msazure/One/Azure-Messaging-AI-Context](https://dev.azure.com/msazure/One/_git/Azure-Messaging-AI-Context),
whose `upstream/master` branch follows this repository's `master`. Agency jobs
can't load plugins from the `Azure` GitHub organization yet. Pin the plugin to a
reviewed commit of that branch, so a pull request can't change the agent or the
rules that review it.

`.azuredevops/policies/agency-triggers.yml`, with the plugin spec
`ado-git:msazure/One/Azure-Messaging-AI-Context:plugins/azure-messaging-review@<commit>`:

```yaml
configuration:
  agencyTriggers:
  - name: agency-review
    eventTypes:
    - "PullRequestPublished"
    - "PullRequestCommitPublished"
    filter:
      pullRequest:
        authorTypes:
        - user
    job:
      # A full review every time: Agency Review otherwise reviews only the
      # changes after the newest iteration in any Agency-signed thread, and the
      # strict rules review's threads carry the same signature.
      prompt: "Run a full re-review of this pull request: review every change in the pull request, not only the changes since the last review."
      agent:
        name: "agency-code-review"
        pluginName: "agency-review"
        type: Company
      plugins:
      - name: "agency-review"
        type: Company
      - name: "<plugin spec>"
        type: Spec
  - name: strict-rules-review
    eventTypes:
    - "PullRequestPublished"
    - "PullRequestCommitPublished"
    filter:
      pullRequest:
        authorTypes:
        - user
    job:
      agent:
        name: "strict-rules-review"
        pluginName: "azure-messaging-review"
        type: Spec
      plugins:
      - name: "<plugin spec>"
        type: Spec
```

`agency.toml`:

```toml
[plugins]
default = ["local:./deps/azure-messaging-ai-context/plugins/azure-messaging-review"]

# Agency Review
[review.default]
muteBelowSeverity = "info"

[[review.default.guidelines]]
source = "azure-messaging-review:design-doc-guidelines"

# Strict rules review. It matches no branch, so Agency Review always selects
# [review.default]; the strict rules agent selects it by name.
[review.strict]
branches = ["!**"]
muteBelowSeverity = "info"

[review.strict.domainReviewers.general]
enabled = false

[[review.strict.guidelines]]
source = "azure-messaging-review:ctest-guidelines"

[[review.strict.guidelines]]
source = "azure-messaging-review:design-doc-conventions"
```

`muteBelowSeverity = "info"` posts every finding as an active thread, so the
Comment requirements branch policy blocks completion until someone fixes or
resolves it.

The `local:` entry is for local runs from a checkout that has this repository
as the `deps/azure-messaging-ai-context` submodule; pull request reviews load
the plugin from the trigger's `job.plugins` entry. A local run prints its
findings and never posts them:

```powershell
agency copilot --plugin market:agency-review@agency-microsoft/.github-private --allow-all `
    -p "/agency-review Review ADO pull request <id>"
agency copilot --agent azure-messaging-review:strict-rules-review --allow-all `
    -p "Review pull request <id> in <org>/<project>/<repository>."
```