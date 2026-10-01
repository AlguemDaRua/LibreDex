# LibreDex documentation

Start here to find the right guide. The icons are navigation cues: **🧭 overview**, **🗃 data**, **⚔️ battle rules**, **🧪 verification**, and **🚀 release**.

| Guide | What it covers |
| --- | --- |
| [Audit implementation guide](audit-implementation.md) | Architecture, user-facing behavior, filter/count semantics, randomizer, navigation, evolution coverage, and current verification limits. |
| [Data pipeline and provenance](data-pipeline.md) | Data sources, origin-versus-regulation policy, asset builders, safe regeneration order, and validators. |
| [Champions Regulation M-C](champions-support.md) | Version 1.2.0 snapshot, roster and catalog deltas, regulation-specific learnsets/PP, Mega abilities, and official/community sources. |
| [Legends: Z-A support](legends-za-support.md) | Mega form overlay, Mega Dimension coverage, game-origin labels, and source boundaries. |
| [Database schema and migrations](database-migrations.md) | Drift schema, schema-vs-bundle versions, upgrade/reseed behavior, and migration maintenance. |
| [Testing LibreDex](testing.md) | Test inventory, asset validators, commands, and the verification work still required. |
| [Release checklist](release-checklist.md) | Pre-release data, migration, UI, accessibility, and Flutter checks. |
| [Third-party notices](../NOTICE.md) | PokéAPI, artwork, trademark, and code-license attribution. |

## 🧭 Maintenance rule of thumb

For an **asset-only data correction**, update the relevant JSON/CSV source and provenance notes, validate the asset references, and increment `SyncRepository.bundledDataVersion`. For a **database shape change**, update the Drift table, migration, `schemaVersion`, and generated code as well; a bundle-version bump cannot add a SQL column. See [Database migrations](database-migrations.md) and [Data pipeline](data-pipeline.md) before changing either layer.
