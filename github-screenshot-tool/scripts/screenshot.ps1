# screenshot.ps1 - PowerShell script for capturing screenshots on Windows

<#
.SYNOPSIS
    Captures a screenshot of the primary screen and saves it as a PNG file.

.DESCRIPTION
    This script uses System.Windows.Forms and System.Drawing assemblies to capture
    the entire primary screen and save it as a PNG file. It's designed to be called
    from OpenClaw skills when browser automation tools are unavailable.

.PARAMETER OutputPath
    The full path where the screenshot should be saved. If not specified, a default
    filename with timestamp will be used in the current directory.

.PARAMETER Quality
    The quality level for PNG compression (not applicable for PNG format, reserved for future JPEG support).

.EXAMPLE
    .\screenshot.ps1 -OutputPath "C:\screenshots\my_screenshot.png"

.EXAMPLE
    .\screenshot.ps1  # Uses default filename with timestamp

.NOTES
    Author: OpenClaw Screenshot Tool Skill
    Version: 1.0.0
    Requires: Windows, PowerShell 5.1 or higher
#>

param(
    [string]$OutputPath,
    [int]$Quality = 100
)

# Function to capture screenshot
function Capture-Screenshot {
    try {
        # Load required assemblies
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        
        Write-Host "Capturing screenshot..." -ForegroundColor Cyan
        
        # Get primary screen bounds
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen
        $bounds = $screen.Bounds
        
        Write-Host "Screen resolution: $($bounds.Width)x$($bounds.Height)" -ForegroundColor Cyan
        
        # Create bitmap and graphics objects
        $bitmap = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Capture screen
        $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
        
        Write-Host "Screenshot captured successfully" -ForegroundColor Green
        
        return @{
            Bitmap = $bitmap
            Graphics = $graphics
            Width = $bounds.Width
            Height = $bounds.Height
        }
    }
    catch {
        Write-Host "Error capturing screenshot: $_" -ForegroundColor Red
        throw $_
    }
}

# Function to save screenshot
function Save-Screenshot {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [System.Drawing.Graphics]$Graphics,
        [string]$FilePath
    )
    
    try {
        # Ensure directory exists
        $directory = Split-Path -Path $FilePath -Parent
        if (-not (Test-Path -Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
            Write-Host "Created directory: $directory" -ForegroundColor Yellow
        }
        
        # Save the bitmap
        $Bitmap.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Get file info
        $fileInfo = Get-Item -Path $FilePath
        $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
        
        Write-Host "Screenshot saved to: $FilePath" -ForegroundColor Green
        Write-Host "File size: $fileSizeKB KB" -ForegroundColor Green
        
        return @{
            Path = $FilePath
            SizeKB = $fileSizeKB
            Width = $Bitmap.Width
            Height = $Bitmap.Height
            Created = $fileInfo.CreationTime
        }
    }
    catch {
        Write-Host "Error saving screenshot: $_" -ForegroundColor Red
        throw $_
    }
    finally {
        # Clean up resources
        if ($Graphics) {
            $Graphics.Dispose()
        }
        if ($Bitmap) {
            $Bitmap.Dispose()
        }
    }
}

# Main execution
try {
    # Generate default output path if not provided
    if (-not $OutputPath) {
        $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        $OutputPath = Join-Path $scriptDir "screenshot_$timestamp.png"
    }
    
    # Capture screenshot
    $capture = Capture-Screenshot
    
    # Save screenshot
    $result = Save-Screenshot -Bitmap $capture.Bitmap -Graphics $capture.Graphics -FilePath $OutputPath
    
    # Output result as JSON for programmatic use
    $resultJson = $result | ConvertTo-Json -Compress
    Write-Host "RESULT:$resultJson"
    
    exit 0
}
catch {
    Write-Host "ERROR:$($_.ToString())" -ForegroundColor Red
    exit 1
}