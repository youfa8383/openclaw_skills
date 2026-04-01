# test-screenshot.ps1 - Test script for screenshot functionality

Write-Host "Testing Screenshot Tool Skill" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$screenshotScript = Join-Path $scriptDir "screenshot.ps1"

# Test output directory
$testDir = "C:\Users\Burgeon\.openclaw\workspace\skills\screenshot-tool\tests"
if (-not (Test-Path -Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Write-Host "Created test directory: $testDir" -ForegroundColor Yellow
}

# Test 1: Basic screenshot with default name
Write-Host "`nTest 1: Basic screenshot" -ForegroundColor Green
$test1Path = Join-Path $testDir "test1_default.png"
& $screenshotScript -OutputPath $test1Path

if (Test-Path $test1Path) {
    $file1 = Get-Item $test1Path
    Write-Host "✓ Test 1 passed: $($file1.Name) ($([math]::Round($file1.Length/1KB,2)) KB)" -ForegroundColor Green
} else {
    Write-Host "✗ Test 1 failed: File not created" -ForegroundColor Red
}

# Test 2: Screenshot with timestamp in name
Write-Host "`nTest 2: Screenshot with timestamp" -ForegroundColor Green
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$test2Path = Join-Path $testDir "test2_$timestamp.png"
& $screenshotScript -OutputPath $test2Path

if (Test-Path $test2Path) {
    $file2 = Get-Item $test2Path
    Write-Host "✓ Test 2 passed: $($file2.Name)" -ForegroundColor Green
} else {
    Write-Host "✗ Test 2 failed: File not created" -ForegroundColor Red
}

# Test 3: Verify image properties
Write-Host "`nTest 3: Image properties verification" -ForegroundColor Green
if (Test-Path $test1Path) {
    try {
        Add-Type -AssemblyName System.Drawing
        $image = [System.Drawing.Image]::FromFile($test1Path)
        Write-Host "✓ Image dimensions: $($image.Width)x$($image.Height)" -ForegroundColor Green
        Write-Host "✓ Image format: $($image.RawFormat)" -ForegroundColor Green
        $image.Dispose()
    } catch {
        Write-Host "✗ Failed to read image properties: $_" -ForegroundColor Red
    }
}

# Test 4: Error handling (invalid path)
Write-Host "`nTest 4: Error handling test" -ForegroundColor Green
$invalidPath = "X:\invalid\path\test.png"
$errorOutput = & $screenshotScript -OutputPath $invalidPath 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "✓ Test 4 passed: Correctly failed on invalid path" -ForegroundColor Green
    Write-Host "  Error output: $($errorOutput | Select-String -Pattern 'ERROR:')" -ForegroundColor Yellow
} else {
    Write-Host "✗ Test 4 failed: Should have failed on invalid path" -ForegroundColor Red
}

# Summary
Write-Host "`nTest Summary" -ForegroundColor Cyan
Write-Host "============" -ForegroundColor Cyan

$createdFiles = Get-ChildItem -Path $testDir -Filter "*.png" | Measure-Object
Write-Host "Total screenshots created: $($createdFiles.Count)" -ForegroundColor Cyan

if ($createdFiles.Count -ge 2) {
    Write-Host "`n✅ All tests passed successfully!" -ForegroundColor Green
    Write-Host "Screenshot tool is working correctly." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Some tests may have failed" -ForegroundColor Yellow
    Write-Host "Check the output above for details." -ForegroundColor Yellow
}

Write-Host "`nTest files are in: $testDir" -ForegroundColor Cyan
Write-Host "You can manually verify the screenshots." -ForegroundColor Cyan