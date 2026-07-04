# Скачивает libsqlite3 для Android в tool/ (hooks: test-sqlite3, directory: tool/).
$ErrorActionPreference = 'Stop'
$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$tag = 'sqlite3-3.2.0'
$baseUrl = "https://github.com/simolus3/sqlite3.dart/releases/download/$tag"
$destDir = Join-Path $projectRoot 'tool'

$assets = @(
  'libsqlite3.arm.android.so',
  'libsqlite3.arm64.android.so',
  'libsqlite3.x64.android.so',
  'libsqlite3.ia32.android.so'
)

New-Item -ItemType Directory -Force -Path $destDir | Out-Null

foreach ($name in $assets) {
  $dest = Join-Path $destDir $name
  $tmp = Join-Path $env:TEMP "sqlite3_$name"
  Write-Host "Downloading $name ..."
  curl.exe -L --connect-timeout 60 --max-time 600 -o $tmp "$baseUrl/$name"
  $size = (Get-Item $tmp).Length
  if ($size -lt 1000) {
    throw "Download failed or empty: $name ($size bytes)"
  }
  Copy-Item -Force $tmp $dest
  Remove-Item -Force $tmp
  Write-Host "Saved -> $dest ($size bytes)"
}

Write-Host "Done. Prebuilt libs: $destDir"
