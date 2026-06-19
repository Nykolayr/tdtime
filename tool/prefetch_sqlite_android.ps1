# Скачивает libsqlite3 для Android и кладёт в кэш Dart hooks (обход таймаута HttpClient).
$ErrorActionPreference = 'Stop'
$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$tag = 'sqlite3-3.2.0'
$baseUrl = "https://github.com/simolus3/sqlite3.dart/releases/download/$tag"
$sharedRoot = Join-Path $projectRoot '.dart_tool\hooks_runner\shared\sqlite3\build'

# Имя файла на GitHub -> папка кэша hooks (см. sqlite3 PrebuiltSqliteLibrary.dirname)
$assets = @{
  'libsqlite3.arm.android.so'    = 'download-11f531fe'
  'libsqlite3.arm64.android.so'  = 'download-2996666'
  'libsqlite3.x64.android.so'      = 'download-1da84213'
  'libsqlite3.ia32.android.so'     = 'download-1d8d3dc4'
}

New-Item -ItemType Directory -Force -Path $sharedRoot | Out-Null

foreach ($entry in $assets.GetEnumerator()) {
  $name = $entry.Key
  $cacheDir = Join-Path $sharedRoot $entry.Value
  $dest = Join-Path $cacheDir 'libsqlite3.so'
  New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null

  $tmp = Join-Path $env:TEMP "sqlite3_$name"
  Write-Host "Downloading $name ..."
  curl.exe -L --connect-timeout 60 --max-time 600 -o $tmp "$baseUrl/$name"
  $size = (Get-Item $tmp).Length
  if ($size -lt 1000) {
    Write-Warning "Skip missing: $name"
    Remove-Item -Force $tmp -ErrorAction SilentlyContinue
    continue
  }
  Copy-Item -Force $tmp $dest
  Remove-Item -Force $tmp
  Write-Host "Cached -> $dest ($size bytes)"
}

Write-Host "Done. Cache: $sharedRoot"
