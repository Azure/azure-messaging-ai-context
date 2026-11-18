# azure-messaging-review

Review rules for [Agency Review](https://eng.ms/docs/agency/partners/agencyreview/agency-review)
in the Azure Messaging C repositories. Agency Review runs on every pull request
in the repositories that opt in, applies these rules next to its general review,
and posts findings as pull request threads.

## Layout

```
plugins/azure-messaging-review/
├── plugin.json             # Plugin manifest
├── agency.json             # Agency metadata (pluginId, engines)
└── skills/
    └── ctest-guidelines/   # One skill per rule family
        ├── SKILL.md        # Context for reviewers
        └── reference/
            └── parameterized-tests.guidelines.md
```

Each skill is one family of rules. Its `SKILL.md` gives reviewers background,
and each `reference/*.guidelines.md` file holds rules in the
[guideline format](https://eng.ms/docs/agency/partners/agencyreview/agency-review#guidelines):
a frontmatter `applyTo` glob that limits which changed files the file applies
to, then one section per rule with a stable ID.

## Rules

| Skill              | Rules                                  | Applies to                             |
|--------------------|----------------------------------------|----------------------------------------|
| `ctest-guidelines` | `CTEST-PARAM-001` to `CTEST-PARAM-003` | `**/tests/**/*.c`, `**/tests/**/*.cpp` |

## Adding a rule

- Add a rule to an existing `*.guidelines.md` file, or add a new file under the
  skill's `reference/` folder with its own `applyTo`.
- Add a new skill for a new family of rules, then add it to the
  `[[review.default.guidelines]]` list of the repositories that should use it.
- Give each rule a new, unique ID and never reuse a retired one.
- Describe the concrete consequence of a violation. The guidelines reviewer only
  reports a finding when it can show an impact, and the impact decides the
  severity (`blocking`, `suggestion` or `info`).

## Using the plugin

Azure DevOps repositories load the plugin from the Azure DevOps mirror of this
repository,
[msazure/One/Azure-Messaging-AI-Context](https://dev.azure.com/msazure/One/_git/Azure-Messaging-AI-Context),
whose `upstream/master` branch follows this repository's `master`. Agency jobs
can't load plugins from the `Azure` GitHub organization yet.

`.azuredevops/policies/agency-triggers.yml`:

```yaml
job:
  agent:
    name: "agency-code-review"
    pluginName: "agency-review"
    type: Company
  plugins:
  - name: "agency-review"
    type: Company
  - name: "ado-git:msazure/One/Azure-Messaging-AI-Context:plugins/azure-messaging-review@upstream/master"
    type: Spec
```

`agency.toml`:

```toml
[plugins]
default = ["local:./deps/azure-messaging-ai-context/plugins/azure-messaging-review"]

[[review.default.guidelines]]
source = "azure-messaging-review:ctest-guidelines"
```

The `local:` entry is for local `/agency-review` runs from a checkout that has
this repository as the `deps/azure-messaging-ai-context` submodule; pull request
reviews load the plugin from the trigger's `job.plugins` entry.
