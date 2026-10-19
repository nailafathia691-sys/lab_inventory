[CmdletBinding()]
param(
    [switch]$Demo,
    [string]$Device
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$flutterArguments = @('run')
if ($Device) {
    $flutterArguments += @('-d', $Device)
}

if ($Demo) {
    $applicationFlavor = 'demo'
    $flutterArguments += @('-t', 'lib/main_demo.dart')
} else {
    $applicationFlavor = 'production'
    $configurationFile = Join-Path $projectRoot 'config\supabase.local.json'
    if (-not (Test-Path -LiteralPath $configurationFile -PathType Leaf)) {
        throw 'Konfigurasi Supabase belum ada. Salin config/supabase.example.json menjadi config/supabase.local.json dan isi URL serta public key. Untuk demo, jalankan tools/run.ps1 -Demo.'
    }
    $configuration = Get-Content -LiteralPath $configurationFile -Raw | ConvertFrom-Json
    if ([string]::IsNullOrWhiteSpace($configuration.SUPABASE_URL) -or
        [string]::IsNullOrWhiteSpace($configuration.SUPABASE_PUBLISHABLE_KEY) -or
        $configuration.SUPABASE_URL -match 'YOUR_PROJECT' -or
        $configuration.SUPABASE_PUBLISHABLE_KEY -match 'REPLACE_WITH') {
        throw 'Isi URL dan public key proyek asli pada config/supabase.local.json sebelum menjalankan production.'
    }
    $flutterArguments += @(
        '-t', 'lib/main.dart',
        "--dart-define-from-file=$configurationFile"
    )
}

if ($Device -notin @('chrome', 'edge', 'web-server')) {
    $flutterArguments += @('--flavor', $applicationFlavor)
}

Push-Location -LiteralPath $projectRoot
try {
    & flutter @flutterArguments
    $flutterExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $flutterExitCode
