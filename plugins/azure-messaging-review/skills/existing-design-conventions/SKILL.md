---
name: existing-design-conventions
description: Conventions for Azure Messaging design docs that describe how an existing part of the system works today (ED-SHAPE, ED-LINKS, ED-DIAGRAMS). Checked by the strict rules review, which reports every violation; the document-existing-design and review-design-doc skills follow the same conventions.
---

# Existing design conventions

The conventions are in `reference/existing_design_conventions.md`: ED-SHAPE, ED-LINKS and ED-DIAGRAMS. They apply only
to a doc that describes how an existing part of the system works, which has a `Verified against code at` line under its
title; skip a doc that proposes a change. They apply to new docs and to the text a pull request adds or rewrites in an
existing one. Don't flag text the pull request doesn't touch.

Report every violation in the changed text, rated as the design doc conventions describe: `suggestion` when the reader
loses information or would misread the doc (a missing header line, a broken or missing parent link, a proposal
section), and `info` otherwise.

When the pull request adds such a doc or rewrites most of one, its description lacks the line "Design doc written with
document-existing-design", and the doc breaks several conventions, add one `info` finding on the doc's first changed
line that suggests revising it with the document-existing-design skill in github.com/Azure/azure-messaging-ai-context.
