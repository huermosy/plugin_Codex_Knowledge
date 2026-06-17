param(
  [string]$Profile = "default",
  [string]$Proxy = "http://10.1.204.246:8080"
)

$ErrorActionPreference = "Stop"

if ($Proxy -and -not $env:HTTPS_PROXY) {
  $env:HTTP_PROXY = $Proxy
  $env:HTTPS_PROXY = $Proxy
}

if (-not $env:NO_PROXY) {
  $env:NO_PROXY = "127.0.0.1,localhost"
}

function Invoke-Step {
  param(
    [string]$Name,
    [scriptblock]$Body
  )

  Write-Host ""
  Write-Host "== $Name =="
  try {
    & $Body
    if ($LASTEXITCODE) {
      throw "Command exited with code $LASTEXITCODE"
    }
    Write-Host "[ok] $Name"
  } catch {
    Write-Host "[failed] $Name"
    Write-Host $_.Exception.Message
  }
}

Invoke-Step "nlm on PATH" {
  Get-Command nlm | Select-Object Source
}

Invoke-Step "notebooklm-mcp on PATH" {
  Get-Command notebooklm-mcp | Select-Object Source
}

Invoke-Step "CLI auth check" {
  nlm login --check --profile $Profile
}

Invoke-Step "Doctor" {
  nlm doctor -v
}

Invoke-Step "Notebook list" {
  nlm notebook list --profile $Profile
}
