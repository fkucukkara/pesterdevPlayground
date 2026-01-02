<#
.SYNOPSIS
    Run all Pester tests in the playground repository.

.DESCRIPTION
    This script runs all test files in the pesterdevPlayground repository,
    organized by level, and provides a summary of results.

.PARAMETER Level
    Specific level to test (1-4). If not specified, runs all levels.

.PARAMETER DetailedOutput
    Show detailed test output instead of summary.

.PARAMETER CodeCoverage
    Generate code coverage report.

.EXAMPLE
    .\RunAllTests.ps1
    Runs all tests with summary output

.EXAMPLE
    .\RunAllTests.ps1 -Level 2 -DetailedOutput
    Runs only Level 2 tests with detailed output

.EXAMPLE
    .\RunAllTests.ps1 -CodeCoverage
    Runs all tests and generates code coverage report
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateRange(1, 4)]
    [int]$Level,

    [Parameter()]
    [switch]$DetailedOutput,

    [Parameter()]
    [switch]$CodeCoverage
)

# Ensure we're in the repository root
$repoRoot = $PSScriptRoot
Set-Location $repoRoot

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       Pester Testing Playground - Test Runner                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check if Pester is installed
$pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -ge '5.0.0' }
if (-not $pesterModule) {
    Write-Warning "Pester 5.x or higher is not installed!"
    Write-Host "`nTo install Pester, run:" -ForegroundColor Yellow
    Write-Host "  Install-Module -Name Pester -Force -SkipPublisherCheck`n" -ForegroundColor Yellow
    exit 1
}

Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
Write-Host "✓ Pester $($pesterModule[0].Version) loaded`n" -ForegroundColor Green

# Define test levels
$levels = @(
    @{ Number = 1; Path = '01-Basic'; Name = 'Basic Testing' }
    @{ Number = 2; Path = '02-Intermediate'; Name = 'Intermediate Testing (TestCases)' }
    @{ Number = 3; Path = '03-Advanced'; Name = 'Advanced Testing (Mocking)' }
    @{ Number = 4; Path = '04-Expert'; Name = 'Expert Testing (File I/O)' }
)

# Filter by level if specified
if ($Level) {
    $levels = $levels | Where-Object { $_.Number -eq $Level }
}

# Prepare results collection
$allResults = @()

# Run tests for each level
foreach ($levelInfo in $levels) {
    $levelPath = Join-Path -Path $repoRoot -ChildPath $levelInfo.Path
    
    if (-not (Test-Path $levelPath)) {
        Write-Warning "Level path not found: $levelPath"
        continue
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  Level $($levelInfo.Number): $($levelInfo.Name)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

    # Configure Pester
    $config = New-PesterConfiguration
    $config.Run.Path = $levelPath
    $config.Run.PassThru = $true
    
    if ($DetailedOutput) {
        $config.Output.Verbosity = 'Detailed'
    }
    else {
        $config.Output.Verbosity = 'Normal'
    }

    # Enable code coverage if requested
    if ($CodeCoverage) {
        $config.CodeCoverage.Enabled = $true
        $config.CodeCoverage.Path = Get-ChildItem -Path $levelPath -Filter "*.ps1" -Exclude "*.Tests.ps1" | 
            Select-Object -ExpandProperty FullName
        $config.CodeCoverage.OutputFormat = 'JaCoCo'
        $config.CodeCoverage.OutputPath = Join-Path -Path $repoRoot -ChildPath "Coverage-Level$($levelInfo.Number).xml"
    }

    # Run tests
    $result = Invoke-Pester -Configuration $config

    # Store results
    $allResults += @{
        Level = $levelInfo.Number
        Name = $levelInfo.Name
        Result = $result
    }

    Write-Host ""
}

# Display summary
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                     SUMMARY                                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$totalPassed = 0
$totalFailed = 0
$totalSkipped = 0
$totalDuration = [TimeSpan]::Zero

foreach ($item in $allResults) {
    $result = $item.Result
    $totalPassed += $result.PassedCount
    $totalFailed += $result.FailedCount
    $totalSkipped += $result.SkippedCount
    $totalDuration = $totalDuration.Add($result.Duration)

    $statusIcon = if ($result.FailedCount -eq 0) { "✓" } else { "✗" }
    $statusColor = if ($result.FailedCount -eq 0) { "Green" } else { "Red" }

    Write-Host "  Level $($item.Level): $($item.Name)" -NoNewline
    Write-Host " [$statusIcon]" -ForegroundColor $statusColor
    Write-Host "    Passed: $($result.PassedCount) | Failed: $($result.FailedCount) | Skipped: $($result.SkippedCount)" -ForegroundColor Gray
}

Write-Host "`n  ─────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  Total Tests: " -NoNewline
Write-Host "$($totalPassed + $totalFailed + $totalSkipped)" -ForegroundColor White -NoNewline
Write-Host " | Duration: " -NoNewline
Write-Host "$($totalDuration.TotalSeconds.ToString('F2'))s" -ForegroundColor White

Write-Host "`n  Passed:  " -NoNewline
Write-Host $totalPassed -ForegroundColor Green
Write-Host "  Failed:  " -NoNewline
Write-Host $totalFailed -ForegroundColor $(if ($totalFailed -eq 0) { "Green" } else { "Red" })
Write-Host "  Skipped: " -NoNewline
Write-Host $totalSkipped -ForegroundColor Yellow

# Final status
Write-Host ""
if ($totalFailed -eq 0) {
    Write-Host "  🎉 All tests passed! Great job!" -ForegroundColor Green
}
else {
    Write-Host "  ⚠️  Some tests failed. Review the output above." -ForegroundColor Red
}

# Code coverage summary
if ($CodeCoverage) {
    Write-Host "`n  Code Coverage Reports Generated:" -ForegroundColor Cyan
    Get-ChildItem -Path $repoRoot -Filter "Coverage-*.xml" | ForEach-Object {
        Write-Host "    - $($_.Name)" -ForegroundColor Gray
    }
}

Write-Host "`n╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Exit with appropriate code
exit $totalFailed
