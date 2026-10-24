# Deploy the built Flutter web app to GitHub Pages (gh-pages branch).
# Usage:
#   1. flutter build web --release --base-href=/Medi-Connect-/
#   2. pwsh scripts/deploy_web.ps1
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot 'mobile\build\web'
$target = Join-Path $env:TEMP 'mediconnect_ghpages'

if (-not (Test-Path (Join-Path $source 'index.html'))) {
    Write-Error "Build output not found at $source - run the flutter build first."
}

if (Test-Path $target) { Remove-Item $target -Recurse -Force }
New-Item $target -ItemType Directory | Out-Null
Copy-Item "$source\*" $target -Recurse -Force

Push-Location $target
try {
    git init -b gh-pages 2>$null | Out-Null
    git checkout -b gh-pages 2>$null | Out-Null
    git config user.name "tatheer583"
    git config user.email "tatheer583@users.noreply.github.com"
    git add -A
    git commit -m "Deploy web app $(Get-Date -Format 'yyyy-MM-dd HH:mm')" | Out-Null
    git remote add origin https://github.com/tatheer583/Medi-Connect-.git 2>$null
    git push -f origin gh-pages
    Write-Host "`nDeployed! Live URL: https://tatheer583.github.io/Medi-Connect-/" -ForegroundColor Green
} finally {
    Pop-Location
}
