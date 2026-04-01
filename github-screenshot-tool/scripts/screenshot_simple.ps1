# screenshot_simple.ps1 - 简单可靠的截图脚本

param([string]$OutputPath)

Add-Type -AssemblyName System.Drawing

$width = 1920
$height = 1080

if (-not $OutputPath) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $OutputPath = "C:\Users\Burgeon\.openclaw\workspace\screenshots\screenshot_$timestamp.png"
}

$directory = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

try {
    $bitmap = [System.Drawing.Bitmap]::new($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    $graphics.CopyFromScreen(0, 0, 0, 0, [System.Drawing.Size]::new($width, $height))
    
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $fileInfo = Get-Item -Path $OutputPath
    $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
    
    $result = @{
        success = $true
        path = $OutputPath
        sizeKB = $fileSizeKB
        width = $width
        height = $height
        created = $fileInfo.CreationTime.ToString('yyyy-MM-dd HH:mm:ss')
    }
    
    $resultJson = $result | ConvertTo-Json -Compress
    Write-Host "RESULT:$resultJson"
    
    $graphics.Dispose()
    $bitmap.Dispose()
    
    exit 0
    
} catch {
    $errorResult = @{
        success = $false
        error = $_.ToString()
    }
    
    $errorJson = $errorResult | ConvertTo-Json -Compress
    Write-Host "ERROR:$errorJson"
    
    exit 1
}