# Codex Knowledge Plugins

This repository packages three personal Codex plugins so they can be moved to another machine and reinstalled with a small amount of per-machine setup:

- `notebooklm`
- `notion`
- `obsidian`

The repository is portable by design:

- no machine-local absolute paths are committed
- no live access token is committed
- per-machine MCP details are filled in after cloning

## Repository layout

```text
.agents/plugins/marketplace.json
plugins/notebooklm
plugins/notion
plugins/obsidian
```

## Install on another machine

1. Clone this repository to a local folder.
2. Copy `.agents/plugins/marketplace.json` into the target machine's personal marketplace location if needed:

```text
%USERPROFILE%\.agents\plugins\marketplace.json
```

3. Copy the `plugins/` folder to:

```text
%USERPROFILE%\plugins
```

4. Fill in each plugin's local MCP configuration as described below.
5. In Codex, reinstall the plugin from the personal marketplace:

```text
codex plugin add notebooklm@personal
codex plugin add notion@personal
codex plugin add obsidian@personal
```

6. Start a new Codex thread before testing updated plugin tools.

## Per-plugin setup

### NotebookLM

Edit `plugins/notebooklm/.mcp.json` for the current machine:

- set `command` to the local `notebooklm-mcp` executable path
- add proxy values only if the machine needs them

### Notion

`plugins/notion/.mcp.json` points to the hosted Notion MCP endpoint and usually needs no change.

### Obsidian

Edit `plugins/obsidian/.mcp.json` for the current machine:

- confirm the local MCP URL
- replace `YOUR_OBSIDIAN_MCP_BEARER_TOKEN` with the token from your Obsidian MCP plugin

## Security note

Do not commit live tokens, local proxy secrets, or machine-only absolute paths back into this repository.
