---
name: notebooklm-mcp-first
description: Operate NotebookLM through the notebooklm MCP server first. Use for creating notebooks, adding sources, writing notes, listing notebooks, querying sources, and diagnosing NotebookLM connectivity from Codex.
---

# NotebookLM MCP First

Use this skill whenever the user asks Codex to operate NotebookLM.

## Primary Rule

Use the NotebookLM MCP tools as the control plane. Do not use browser automation for NotebookLM writes unless the user explicitly asks for a browser-driven fallback or the MCP route is unavailable and the user approves a fallback.

Preferred tool families:

- `mcp__notebooklm.server_info`
- `mcp__notebooklm.notebook_list`
- `mcp__notebooklm.notebook_create`
- `mcp__notebooklm.notebook_get`
- `mcp__notebooklm.note`
- `mcp__notebooklm.source_add`
- `mcp__notebooklm.notebook_query`

For CLI diagnostics, use the persisted local executables installed by `uv tool install notebooklm-mcp-cli`:

- `nlm login --check`
- `nlm doctor -v`
- `nlm notebook list`
- `nlm notebook create "Title" --json`
- `nlm note create <notebook_id> --title "Title" --content "Content"`

This local plugin starts `notebooklm-mcp` from the path configured in:

```text
plugins/notebooklm/.mcp.json
```

If a machine needs an HTTP proxy for NotebookLM access, add `HTTP_PROXY` and `HTTPS_PROXY` in that local `.mcp.json`.

## Health Check

Before writing data, run a lightweight MCP health check:

1. Call `mcp__notebooklm.server_info`.
2. If `auth_status` is `configured`, continue.
3. If `auth_status` is `unverified`, try one real read such as `mcp__notebooklm.notebook_list`.
4. If read or list times out or returns auth errors, do not switch to browser automation silently. Explain that the MCP auth path is not ready and run the local health check script if useful.

The plugin includes:

```powershell
plugins/notebooklm/scripts/check-notebooklm-mcp.ps1
```

## Create Notebook And Notes

For a request such as "create a NotebookLM notebook and add two notes":

1. Create the notebook with `mcp__notebooklm.notebook_create`.
2. Capture the returned notebook ID.
3. Add each note with `mcp__notebooklm.note` using `action: "create"`.
4. Verify with `mcp__notebooklm.note` using `action: "list"`.

If the MCP tool is unavailable in the current thread after a plugin update, tell the user a new Codex thread is needed for the refreshed plugin capabilities to load.

If the health check says authentication expired, run:

```powershell
nlm login --profile default
```

Then verify:

```powershell
nlm notebook list --profile default
```

## Fallback Policy

Browser or CDP automation is allowed only as a diagnostic source for login state, page availability, or visual confirmation. It is not the default write path for NotebookLM data.
