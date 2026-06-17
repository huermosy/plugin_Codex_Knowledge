---
name: obsidian-local-first
description: Operate the local Obsidian vault through MCP for reliable reads, and use the local filesystem for writes when bulk import or directory creation is simpler. Use for listing notes, reading notes, and safely creating folders and notes in the local vault.
---

# Obsidian Local First

Use this skill whenever the user asks Codex to operate the local Obsidian vault.

## Primary Rule

Use the local Obsidian MCP service as the primary read plane.

Preferred split:

- `MCP for reads` for both ASCII and Chinese paths when the request is sent as proper UTF-8
- `Local filesystem for writes` when creating folders, importing note batches, or when direct vault writes are simpler than tool calls
- `Local filesystem fallback` only if a specific MCP client path encoding step mangles the request before it reaches the local server

The local MCP server is:

```text
http://127.0.0.1:3001/mcp
```

It is backed by the Obsidian community plugin:

```text
Semantic Notes Vault MCP
```

The local vault used by this plugin depends on the current machine:

```text
Use your local Obsidian vault path
```

## Verified Behavior

Validated on June 17, 2026:

- MCP `initialize` works
- MCP `tools/list` works
- MCP read of ASCII paths works
- MCP read of Chinese paths works when the request is sent as proper UTF-8
- Earlier Chinese-path failures came from an intermediate client-side encoding issue in the testing path, not from the Obsidian MCP server itself
- Direct local file creation inside the vault works and Obsidian picks it up normally

## Health Check

Before using MCP, run a lightweight health check:

1. Confirm `127.0.0.1:3001` is listening
2. Confirm unauthenticated `/mcp` returns `401`
3. Confirm authenticated MCP `initialize` succeeds
4. Prefer one ASCII-path read test using a real note from the current vault
5. Prefer one Chinese-path read test using a real note from the current vault

The plugin includes:

```powershell
plugins/obsidian/scripts/check-obsidian-flow.ps1
```

## Operating Rules

### Use MCP when

- Listing vault contents
- Checking MCP connectivity
- Reading ASCII paths
- Reading Chinese paths
- Inspecting available MCP tools

### Use local filesystem when

- Creating folders
- Writing notes into Chinese-named folders
- Bulk importing note sets
- A specific client path-encoding step mangles the MCP request before it reaches the local server

## Fallback Policy

Do not assume MCP path failures mean Obsidian itself is broken.

If MCP returns path-garbled errors like `??/Qt/...`:

1. Keep Obsidian open
2. Retry with a UTF-8-safe request path
3. If the client path is still mangled, write directly into the vault folder on disk
4. Verify the file exists locally
5. Let Obsidian refresh naturally or reopen the vault if needed

## Current Recommendation

For this machine, the safest default is:

- `MCP for reads`
- `Local filesystem for writes when it is simpler or more predictable`
