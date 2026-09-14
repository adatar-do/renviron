param(
  [string]$Rscript = 'Rscript',
  [string]$Python = 'python'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Push-Location $workspace
try {
  $env:RENV_CONFIG_AUTOLOADER_ENABLED = 'false'
  if ($env:OS -eq 'Windows_NT') { $env:LC_ALL = 'English_United States.utf8' }
  function Invoke-Checked([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Release step failed: $Program" }
  }
  Invoke-Checked $Python @('renviron/scripts/author-docs.py')
  Invoke-Checked $Rscript @('--vanilla', 'renviron/scripts/test-local.R')
  Invoke-Checked $Rscript @('--vanilla', 'renviron/scripts/check-release.R')
  Invoke-Checked $Rscript @('--vanilla', 'renviron/scripts/export-reference.R')
  Invoke-Checked $Python @('renviron/scripts/build-reference.py')
  Invoke-Checked $Rscript @('--vanilla', 'renviron/scripts/build-docs.R')
  Invoke-Checked $Python @('renviron/scripts/check-sites.py', 'artifacts/renviron-release/sites/r', '--kind', 'r')
  Invoke-Checked $Rscript @('--vanilla', 'renviron/scripts/build-distribution.R')
  Invoke-Checked $Rscript @('--vanilla', 'renviron/scripts/check-installer.R')
} finally { Pop-Location }
