# Screenshot Tool Usage Examples

## Basic Usage from OpenClaw

### 1. Direct PowerShell Execution

```powershell
# Execute the screenshot script
& "C:\Users\Burgeon\.openclaw\workspace\skills\screenshot-tool\scripts\screenshot.ps1" -OutputPath "C:\screenshots\test.png"
```

### 2. From JavaScript/OpenClaw Tool

```javascript
// Capture screenshot using exec tool
const result = await exec({
  command: 'powershell -ExecutionPolicy Bypass -File "C:\\Users\\Burgeon\\.openclaw\\workspace\\skills\\screenshot-tool\\scripts\\screenshot.ps1" -OutputPath "C:\\screenshots\\output.png"',
  workdir: "C:\\Users\\Burgeon\\.openclaw\\workspace"
});

// Parse the result
if (result.exitCode === 0) {
  // Extract JSON result from output
  const output = result.stdout;
  const match = output.match(/RESULT:({.*})/);
  if (match) {
    const screenshotInfo = JSON.parse(match[1]);
    console.log(`Screenshot saved: ${screenshotInfo.Path}`);
  }
}
```

### 3. Complete OpenClaw Skill Integration

```javascript
// When skill is triggered
async function handleScreenshotRequest(userId) {
  try {
    // 1. Generate unique filename
    const timestamp = new Date().toISOString().replace(/[:.]/g, '_');
    const screenshotPath = `C:\\Users\\Burgeon\\.openclaw\\workspace\\screenshots\\screenshot_${timestamp}.png`;
    
    // 2. Ensure directory exists
    await exec({
      command: `mkdir "C:\\Users\\Burgeon\\.openclaw\\workspace\\screenshots"`,
      workdir: "C:\\Users\\Burgeon\\.openclaw\\workspace"
    }).catch(() => {}); // Ignore error if directory exists
    
    // 3. Capture screenshot
    const scriptPath = "C:\\Users\\Burgeon\\.openclaw\\workspace\\skills\\screenshot-tool\\scripts\\screenshot.ps1";
    const captureResult = await exec({
      command: `powershell -ExecutionPolicy Bypass -File "${scriptPath}" -OutputPath "${screenshotPath}"`,
      workdir: "C:\\Users\\Burgeon\\.openclaw\\workspace",
      timeout: 10000 // 10 second timeout
    });
    
    if (captureResult.exitCode !== 0) {
      throw new Error(`Screenshot failed: ${captureResult.stderr}`);
    }
    
    // 4. Verify file exists
    const verifyResult = await exec({
      command: `Test-Path "${screenshotPath}"`,
      shell: true
    });
    
    if (verifyResult.stdout.trim() !== 'True') {
      throw new Error('Screenshot file was not created');
    }
    
    // 5. Send to user
    await message({
      action: "send",
      to: userId,
      media: screenshotPath,
      message: "这是您请求的截图"
    });
    
    return {
      success: true,
      path: screenshotPath,
      message: "Screenshot sent successfully"
    };
    
  } catch (error) {
    console.error('Screenshot error:', error);
    return {
      success: false,
      error: error.message
    };
  }
}
```

## Integration with Other Skills

### With DingTalk Integration

```javascript
// Send screenshot via DingTalk
async function sendScreenshotToDingTalk(userId) {
  const screenshot = await captureScreenshot();
  
  await message({
    action: "send",
    channel: "dingtalk-connector",
    to: userId,
    media: screenshot.path,
    caption: "系统截图 - " + new Date().toLocaleString('zh-CN')
  });
}
```

### With Browser Automation Fallback

```javascript
// Try browser first, fallback to system screenshot
async function captureBrowserOrSystemScreenshot(url) {
  try {
    // First try browser tool
    const browserResult = await browser({
      action: "screenshot",
      url: url,
      fullPage: true
    });
    
    return {
      method: "browser",
      data: browserResult.data
    };
    
  } catch (browserError) {
    console.log('Browser screenshot failed, falling back to system screenshot');
    
    // Fallback to system screenshot
    const systemResult = await captureSystemScreenshot();
    
    return {
      method: "system",
      path: systemResult.path,
      fallback: true
    };
  }
}
```

## Command Line Testing

### Test the Script Directly

```powershell
# Navigate to script directory
cd "C:\Users\Burgeon\.openclaw\workspace\skills\screenshot-tool\scripts"

# Test with default filename
.\screenshot.ps1

# Test with custom path
.\screenshot.ps1 -OutputPath "C:\temp\test_screenshot.png"

# Test and capture output
$output = .\screenshot.ps1 -OutputPath "C:\temp\test.png"
if ($LASTEXITCODE -eq 0) {
    $match = $output | Select-String -Pattern 'RESULT:({.*})'
    if ($match) {
        $result = $match.Matches[0].Groups[1].Value | ConvertFrom-Json
        Write-Host "Success: $($result.Path)"
    }
}
```

### Integration Test Script

```powershell
# integration-test.ps1
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$screenshotScript = Join-Path $scriptDir "scripts\screenshot.ps1"

Write-Host "Testing Screenshot Tool..." -ForegroundColor Cyan

# Test 1: Default output
Write-Host "`nTest 1: Default output" -ForegroundColor Yellow
& $screenshotScript

# Test 2: Custom output path
Write-Host "`nTest 2: Custom output path" -ForegroundColor Yellow
$testPath = "C:\temp\screenshot_test_$(Get-Date -Format 'HHmmss').png"
& $screenshotScript -OutputPath $testPath

# Test 3: Verify file creation
Write-Host "`nTest 3: File verification" -ForegroundColor Yellow
if (Test-Path $testPath) {
    $file = Get-Item $testPath
    Write-Host "✓ File created: $($file.FullName)" -ForegroundColor Green
    Write-Host "  Size: $([math]::Round($file.Length/1KB,2)) KB" -ForegroundColor Green
    Write-Host "  Dimensions: (should match your screen resolution)" -ForegroundColor Green
} else {
    Write-Host "✗ File not created" -ForegroundColor Red
}

Write-Host "`nTest completed" -ForegroundColor Cyan
```

## Error Handling Examples

### Graceful Error Recovery

```javascript
async function safeScreenshot(userId) {
  const maxRetries = 2;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`Attempt ${attempt} of ${maxRetries}`);
      
      const result = await captureScreenshotWithRetry();
      
      if (result.success) {
        await sendScreenshotToUser(userId, result.path);
        return { success: true, attempt: attempt };
      }
      
    } catch (error) {
      console.error(`Attempt ${attempt} failed:`, error.message);
      
      if (attempt === maxRetries) {
        await message({
          action: "send",
          to: userId,
          message: `截图失败: ${error.message}`
        });
        return { success: false, error: error.message };
      }
      
      // Wait before retry
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
}
```

### Validation Functions

```javascript
function validateScreenshotResult(execResult) {
  if (execResult.exitCode !== 0) {
    throw new Error(`PowerShell exited with code ${execResult.exitCode}: ${execResult.stderr}`);
  }
  
  const output = execResult.stdout;
  const resultMatch = output.match(/RESULT:({.*})/);
  const errorMatch = output.match(/ERROR:(.*)/);
  
  if (errorMatch) {
    throw new Error(`Script reported error: ${errorMatch[1]}`);
  }
  
  if (!resultMatch) {
    throw new Error('No result found in script output');
  }
  
  try {
    return JSON.parse(resultMatch[1]);
  } catch (parseError) {
    throw new Error(`Failed to parse result JSON: ${parseError.message}`);
  }
}
```

## Performance Tips

1. **Reuse PowerShell sessions**: For multiple screenshots, consider keeping PowerShell alive
2. **Optimize file paths**: Use workspace-relative paths for better portability
3. **Clean up old files**: Implement periodic cleanup of screenshot files
4. **Monitor resource usage**: Screenshots use memory during capture, dispose properly

## Security Considerations

1. **File permissions**: Screenshots may contain sensitive information
2. **Execution policy**: Requires bypass or unrestricted execution policy
3. **User consent**: Always ensure user wants screenshot captured
4. **Data retention**: Consider privacy implications of stored screenshots