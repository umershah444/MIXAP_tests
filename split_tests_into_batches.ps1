# Splits every NNN_*.robot test file in this directory into 3 roughly equal,
# contiguous (numeric-order) batches, and (re)writes run_batch_1.cmd, run_batch_2.cmd,
# run_batch_3.cmd plus run_all_batches.cmd accordingly.
#
# Re-run this script any time test files are added/removed/renamed to keep the
# batches in sync with the current suite - it always reflects what's on disk, it
# never hardcodes a file list.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File split_tests_into_batches.ps1
#
# Then either:
#   - run_batch_1.cmd / run_batch_2.cmd / run_batch_3.cmd individually, or
#   - run_all_batches.cmd to launch all 3 at once in separate windows (parallel -
#     each Robot Framework run opens its own headed Chrome instance).
#
# Each run_batch_N.cmd takes an optional browser argument, passed on to the
# suite as --variable BROWSER:<browser> (default: chrome), e.g.
#   run_batch_1.cmd chrome
#
# Parallel local batches are Chrome-only: run_all_batches.cmd always runs Chrome.
# Safari allows only one WebDriver session per machine and only runs on macOS -
# use run_safari.sh there instead, which runs the suites sequentially.

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$batchCount = 3

$files = Get-ChildItem -Path $scriptDir -Filter '*.robot' |
    Where-Object { $_.Name -match '^\d{3}_' } |
    Sort-Object Name |
    ForEach-Object { $_.Name }

if ($files.Count -eq 0) {
    Write-Error "No NNN_*.robot files found in $scriptDir"
    exit 1
}

$total = $files.Count
$base = [Math]::Floor($total / $batchCount)
$remainder = $total % $batchCount

$batches = @()
$index = 0
for ($i = 0; $i -lt $batchCount; $i++) {
    $size = $base + $(if ($i -lt $remainder) { 1 } else { 0 })
    $batches += , @($files[$index..($index + $size - 1)])
    $index += $size
}

for ($i = 0; $i -lt $batchCount; $i++) {
    $batchNum = $i + 1
    $batchFiles = $batches[$i]
    $outDir = "results_batch$batchNum"
    $cmdPath = Join-Path $scriptDir "run_batch_$batchNum.cmd"

    $cmdLine = "py -m robot --outputdir $outDir --variable BROWSER:%BROWSER% " + ($batchFiles -join ' ')
    $content = @(
        '@echo off',
        'setlocal',
        'cd /d "%~dp0"',
        'set "BROWSER=%~1"',
        'if "%BROWSER%"=="" set "BROWSER=chrome"',
        $cmdLine,
        'pause'
    )
    Set-Content -Path $cmdPath -Value $content -Encoding ASCII

    Write-Host "Wrote run_batch_$batchNum.cmd - $($batchFiles.Count) file(s) -> $outDir"
}

$launcherPath = Join-Path $scriptDir 'run_all_batches.cmd'
$launcherContent = @(
    '@echo off',
    'cd /d "%~dp0"',
    'start "Test batch 1" cmd /k run_batch_1.cmd',
    'start "Test batch 2" cmd /k run_batch_2.cmd',
    'start "Test batch 3" cmd /k run_batch_3.cmd'
)
Set-Content -Path $launcherPath -Value $launcherContent -Encoding ASCII
Write-Host "Wrote run_all_batches.cmd - launches all 3 batches in parallel (Chrome only)"

Write-Host ""
Write-Host "$total test file(s) split into $batchCount batches."
