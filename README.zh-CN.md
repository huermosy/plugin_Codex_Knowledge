# Codex Knowledge Plugins

[English](./README.en.md) | [简体中文](./README.zh-CN.md)

这个仓库打包了三个个人 Codex 插件，方便你迁移到其他电脑，并在做少量本机配置后重新安装使用：

- `notebooklm`
- `notion`
- `obsidian`

当前插件集的评估报告见：

- `PLUGIN_SCORE_REPORT.md`

这个仓库按可移植方式整理：

- 不提交机器本地的绝对路径
- 不提交真实访问令牌
- 每台机器相关的 MCP 配置在克隆后再填写

## 仓库结构

```text
.agents/plugins/marketplace.json
plugins/notebooklm
plugins/notion
plugins/obsidian
```

## 在其他机器上安装

1. 把这个仓库 clone 到本地目录。
2. 如有需要，把 `.agents/plugins/marketplace.json` 复制到目标机器的个人 marketplace 位置：

```text
%USERPROFILE%\.agents\plugins\marketplace.json
```

3. 把 `plugins/` 目录复制到：

```text
%USERPROFILE%\plugins
```

4. 按下面说明填写每个插件的本机 MCP 配置。
5. 在 Codex 中从 personal marketplace 重新安装插件：

```text
codex plugin add notebooklm@personal
codex plugin add notion@personal
codex plugin add obsidian@personal
```

6. 开一个新的 Codex 线程再测试更新后的插件工具。

## 各插件配置

### NotebookLM

根据当前机器情况编辑 `plugins/notebooklm/.mcp.json`：

- 把 `command` 改成当前机器上的 `notebooklm-mcp` 可执行文件路径
- 只有机器确实需要代理时再补充代理配置

### Notion

`plugins/notion/.mcp.json` 指向托管的 Notion MCP 端点，一般不需要修改。

### Obsidian

根据当前机器情况编辑 `plugins/obsidian/.mcp.json`：

- 确认本机 MCP URL
- 把 `YOUR_OBSIDIAN_MCP_BEARER_TOKEN` 替换成你本机 Obsidian MCP 插件的 token

## 安全说明

不要把真实 token、本地代理敏感信息或机器专属绝对路径提交回这个仓库。
