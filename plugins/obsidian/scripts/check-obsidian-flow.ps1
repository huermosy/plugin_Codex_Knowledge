param(
  [string]$VaultRoot = "C:\Users\huchenxi6\Documents\Obsidian Vault",
  [string]$ApiKey = "ciW_AKejzVCGeRk7n808qpG4mV9jzxYdqZfeGdgosjw",
  [string]$McpUrl = "http://127.0.0.1:3001/mcp"
)

$ErrorActionPreference = "Stop"
$script:RequestId = 0
$script:McpSessionId = $null

function Invoke-Step {
  param(
    [string]$Name,
    [scriptblock]$Body
  )

  Write-Host ""
  Write-Host "== $Name =="
  try {
    & $Body
    Write-Host "[ok] $Name"
  } catch {
    Write-Host "[failed] $Name"
    Write-Host $_.Exception.Message
  }
}

function Convert-McpBodyToJson {
  param(
    [string]$Body
  )

  $trimmed = $Body.Trim()
  if ($trimmed.StartsWith("{")) {
    return $trimmed | ConvertFrom-Json
  }

  $dataLines = [regex]::Matches($Body, '(?m)^data:\s?(.*)$') |
    ForEach-Object { $_.Groups[1].Value }

  if (-not $dataLines -or $dataLines.Count -eq 0) {
    throw "No JSON payload found in MCP response body: $Body"
  }

  $jsonText = ($dataLines -join "`n").Trim()
  return $jsonText | ConvertFrom-Json
}

function Invoke-McpJson {
  param(
    [hashtable]$Payload,
    [string]$SessionId
  )

  $script:RequestId++
  $Payload.jsonrpc = "2.0"
  $Payload.id = $script:RequestId

  $json = $Payload | ConvertTo-Json -Depth 8
  $handler = [System.Net.Http.HttpClientHandler]::new()
  $client = [System.Net.Http.HttpClient]::new($handler)

  try {
    $client.DefaultRequestHeaders.Authorization =
      [System.Net.Http.Headers.AuthenticationHeaderValue]::new("Bearer", $ApiKey)
    $client.DefaultRequestHeaders.Accept.ParseAdd("application/json")
    $client.DefaultRequestHeaders.Accept.ParseAdd("text/event-stream")
    if ($SessionId) {
      $client.DefaultRequestHeaders.Add("Mcp-Session-Id", $SessionId)
    }

    $content = [System.Net.Http.StringContent]::new(
      $json,
      [System.Text.Encoding]::UTF8,
      "application/json"
    )
    $response = $client.PostAsync($McpUrl, $content).GetAwaiter().GetResult()
    $body = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()

    if (-not $response.IsSuccessStatusCode) {
      throw "MCP request failed: $([int]$response.StatusCode) $body"
    }

    $responseSessionId = $null
    if ($response.Headers.Contains("Mcp-Session-Id")) {
      $responseSessionId = ($response.Headers.GetValues("Mcp-Session-Id") | Select-Object -First 1)
    }

    [pscustomobject]@{
      SessionId = $responseSessionId
      Json = Convert-McpBodyToJson -Body $body
      RawBody = $body
    }
  } finally {
    $client.Dispose()
    $handler.Dispose()
  }
}

function Get-McpTextContent {
  param(
    $McpResponse
  )

  $items = $McpResponse.Json.result.content
  if (-not $items) {
    return $null
  }

  return ($items | ForEach-Object { $_.text }) -join "`n"
}

$qtNotePath = [string]::Concat(
  [char]0x5B66, [char]0x4E60, "\",
  "Qt", "\",
  "Qt", [char]0x5B66, [char]0x4E60, [char]0x8DEF, [char]0x7EBF, ".md"
)

Invoke-Step "Vault exists" {
  Get-Item -LiteralPath $VaultRoot | Select-Object FullName, Exists
}

Invoke-Step "MCP port 3001" {
  Test-NetConnection -ComputerName 127.0.0.1 -Port 3001 | Select-Object ComputerName, RemotePort, TcpTestSucceeded
}

Invoke-Step "Unauthenticated MCP endpoint returns 401" {
  try {
    Invoke-WebRequest -UseBasicParsing $McpUrl -TimeoutSec 10 | Out-Null
    throw "Expected 401 but request succeeded"
  } catch {
    if (-not $_.Exception.Response -or [int]$_.Exception.Response.StatusCode -ne 401) {
      throw
    }
    "401 as expected"
  }
}

Invoke-Step "Authenticated MCP initialize" {
  $response = Invoke-McpJson @{
    method = "initialize"
    params = @{
      protocolVersion = "2025-03-26"
      capabilities = @{}
      clientInfo = @{
        name = "codex-obsidian-check"
        version = "1.0.0"
      }
    }
  }

  if (-not $response.Json.result.protocolVersion) {
    throw "initialize did not return a protocolVersion"
  }
  if (-not $response.SessionId) {
    throw "initialize did not return a session identifier"
  }

  $script:McpSessionId = $response.SessionId

  [pscustomobject]@{
    protocolVersion = $response.Json.result.protocolVersion
    serverName = $response.Json.result.serverInfo.name
    serverVersion = $response.Json.result.serverInfo.version
    sessionId = $response.SessionId
  }
}

Invoke-Step "MCP tools/list" {
  $response = Invoke-McpJson @{
    method = "tools/list"
    params = @{}
  } $script:McpSessionId

  $toolNames = $response.Json.result.tools | ForEach-Object { $_.name }
  if (-not $toolNames) {
    throw "No tools returned"
  }

  $toolNames
}

Invoke-Step "ASCII-path MCP read" {
  $response = Invoke-McpJson @{
    method = "tools/call"
    params = @{
      name = "vault"
      arguments = @{
        action = "read"
        path = "blogdevteam.md"
      }
    }
  } $script:McpSessionId

  $text = Get-McpTextContent -McpResponse $response
  if (-not $text) {
    throw "vault read did not return text content"
  }

  $text
}

Invoke-Step "Chinese-path MCP read" {
  $response = Invoke-McpJson @{
    method = "tools/call"
    params = @{
      name = "vault"
      arguments = @{
        action = "read"
        path = ($qtNotePath -replace "\\", "/")
      }
    }
  } $script:McpSessionId

  $text = Get-McpTextContent -McpResponse $response
  if (-not $text) {
    throw "vault read did not return text content"
  }

  $text
}

Invoke-Step "ASCII-path local read" {
  Get-Content -Raw -Encoding utf8 (Join-Path $VaultRoot "blogdevteam.md")
}

Invoke-Step "Chinese-path local read" {
  Get-Content -Raw -Encoding utf8 (Join-Path $VaultRoot $qtNotePath)
}
