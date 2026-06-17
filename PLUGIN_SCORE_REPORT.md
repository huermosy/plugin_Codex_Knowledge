# Plugin Score Report

This report evaluates the three Codex knowledge plugins in this repository against practical Codex plugin expectations:

- manifest correctness
- portability across machines
- operational completeness
- security hygiene
- maintainability

Scores are on a `10` point scale.

## Executive Summary

The repository is now suitable for GitHub distribution and cross-machine reuse after the portability cleanup already applied in this repo.

Overall assessment:

- `NotebookLM` is the strongest plugin in the set
- `Notion` is structurally correct but still minimal
- `Obsidian` has strong workflow thinking but needs one more round of polish for portability and documentation consistency

Overall repository score: `8.0/10`

## Score Table

| Plugin | Structure | Portability | Security | Operational completeness | Maintainability | Total |
| --- | --- | --- | --- | --- | --- | --- |
| NotebookLM | 9.0 | 8.5 | 8.5 | 9.0 | 8.8 | `8.8/10` |
| Notion | 8.8 | 9.2 | 9.0 | 5.8 | 7.0 | `7.6/10` |
| Obsidian | 8.8 | 8.0 | 8.4 | 8.3 | 7.8 | `8.1/10` |

## Detailed Review

### NotebookLM

Score: `8.8/10`

Strengths:

- Valid Codex plugin structure with correct manifest and MCP configuration
- Has a real skill file that explains intended control flow
- Includes a health check script and practical troubleshooting guidance
- Uses a workflow that matches real NotebookLM operations well

Weaknesses:

- Requires per-machine executable path setup before use
- Proxy handling is documented but still left to manual setup on each machine
- Depends on a third-party local executable, which raises setup friction for new machines

Recommended optimization items:

1. Add a dedicated setup guide for installing `notebooklm-mcp-cli` on a clean machine.
2. Add a sample `.mcp.local.example.json` or equivalent template for proxy-enabled environments.
3. Add a short validation checklist in the plugin folder for post-install testing.

### Notion

Score: `7.6/10`

Strengths:

- Manifest is valid and clean
- MCP endpoint is portable and does not depend on machine-local paths
- Lowest setup friction of the three plugins

Weaknesses:

- No skill file, so Codex gets less usage guidance than for the other plugins
- No diagnostic script for auth or connectivity checks
- Operational behavior is under-documented compared with the other two plugins

Recommended optimization items:

1. Add `skills/notion-workspace-first/SKILL.md` with clear read and write rules.
2. Add a lightweight `scripts/check-notion-mcp.ps1` for connectivity and auth testing.
3. Add example prompts in documentation for common page and database workflows.

### Obsidian

Score: `8.1/10`

Strengths:

- Good practical design split between MCP reads and local filesystem writes
- Includes both a skill file and a fairly strong diagnostic script
- Covers real operational issues such as path handling and local vault interaction

Weaknesses:

- Still depends on local token injection after clone
- Some wording remains machine-oriented rather than fully distribution-oriented
- The diagnostic and skill docs could better separate example values from required configuration

Recommended optimization items:

1. Move token guidance into a clearer first-run setup section in the plugin folder.
2. Add a sample vault layout and expected MCP tool list for easier verification on another machine.
3. Refine the skill and script docs so example local paths are always clearly placeholders.

## Repository-Level Optimization Items

These items would raise the set from a good personal plugin pack to a more polished reusable package:

1. Add a dedicated setup doc for each plugin under `docs/`.
2. Add a consistent health-check script for all three plugins.
3. Add one shared installation checklist for clean-machine onboarding.
4. Add versioned release notes when plugin behavior changes.
5. Add a `CHANGELOG.md` so future updates are easier to track across machines.

## Final Verdict

This plugin set is already beyond a basic experiment. It is structurally valid, practically useful, and now portable enough to live on GitHub.

The next biggest quality jump will come from improving onboarding and diagnostics, especially for `Notion`, and from making machine-specific setup even more explicit for `NotebookLM` and `Obsidian`.
