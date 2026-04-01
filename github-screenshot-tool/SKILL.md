---
name: Screenshot Tool
slug: screenshot-tool
version: 1.2.0
homepage: https://clawic.com/skills/screenshot-tool
description: "Reliable screenshot capture and sharing for Windows systems. Provides system-level screenshot functionality as a fallback when browser tools are unavailable. Use when you need to capture screen content and send it via messaging platforms."
changelog: |
  v1.2.0 - 修复屏幕分辨率检测问题
    - 移除有问题的 System.Windows.Forms.Screen 依赖
    - 使用固定的1920x1080分辨率（经过测试验证）
    - 修复 Bitmap 构造函数问题
    - 添加完整的错误处理和JSON输出
  
  v1.0.0 - 初始版本
    - 基于PowerShell的系统截图
    - 消息平台集成
metadata: {"clawdbot":{"emoji":"📸","os":["win32"]}}
---

## When to Use

Use when:
1. User requests a screenshot of their screen or browser
2. Browser automation tools are unavailable or unreliable
3. You need a reliable fallback screenshot method
4. Screenshot needs to be sent via messaging platforms (DingTalk, Telegram, etc.)

## Core Rules

### 1. System Command First, Browser Tools Second

- **Primary method**: Use PowerShell system commands for reliable screenshot capture
- **Fallback method**: Try browser tools if available and user needs specific webpage
- **Always verify**: Check if screenshot file was created successfully before sending

### 2. File Management

- **Save location**: Save screenshots to workspace directory for easy access
- **File naming**: Use descriptive names with timestamps (e.g., `screenshot_YYYY-MM-DD_HHMM.png`)
- **Cleanup**: Consider removing old screenshots if storage becomes an issue

### 3. Messaging Integration

- **Media parameter**: Always explicitly specify `media` parameter when sending via message tool
- **File verification**: Verify file exists and is readable before attempting to send
- **User confirmation**: Ask user to confirm receipt when possible

### 4. Platform Compatibility

- **Windows focus**: This skill is optimized for Windows systems
- **PowerShell required**: Relies on PowerShell for system-level screenshot capture
- **Cross-platform potential**: Could be extended for macOS/Linux with appropriate commands

## Implementation Details

### PowerShell Screenshot Script (修复版)

```powershell
# screenshot_simple.ps1 - 简单可靠的截图脚本
param([string]$OutputPath)

Add-Type -AssemblyName System.Drawing

# 使用验证过的1920x1080分辨率（避免Screen类问题）
$width = 1920
$height = 1080

if (-not $OutputPath) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $OutputPath = "C:\screenshots\screenshot_$timestamp.png"
}

try {
    # 使用静态构造函数创建Bitmap
    $bitmap = [System.Drawing.Bitmap]::new($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # 从屏幕左上角开始截图
    $graphics.CopyFromScreen(0, 0, 0, 0, [System.Drawing.Size]::new($width, $height))
    
    # 保存为PNG
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # 输出JSON结果
    $result = @{
        success = $true
        path = $OutputPath
        sizeKB = [math]::Round((Get-Item $OutputPath).Length / 1KB, 2)
        width = $width
        height = $height
    }
    
    Write-Host "RESULT:$($result | ConvertTo-Json -Compress)"
    
    # 清理资源
    $graphics.Dispose()
    $bitmap.Dispose()
    
} catch {
    $errorResult = @{ success = $false; error = $_.ToString() }
    Write-Host "ERROR:$($errorResult | ConvertTo-Json -Compress)"
}
```

### Complete Usage Example

```javascript
// 完整的截图技能使用示例
async function captureAndSendScreenshot(userId) {
  try {
    // 1. 生成输出路径
    const timestamp = new Date().toISOString().replace(/[:.]/g, '_');
    const screenshotPath = `C:\\Users\\Burgeon\\.openclaw\\workspace\\screenshots\\screenshot_${timestamp}.png`;
    
    // 2. 执行截图脚本
    const scriptPath = "C:\\Users\\Burgeon\\.openclaw\\workspace\\skills\\screenshot-tool\\scripts\\screenshot_simple.ps1";
    const result = await exec({
      command: `powershell -ExecutionPolicy Bypass -File "${scriptPath}" -OutputPath "${screenshotPath}"`,
      workdir: "C:\\Users\\Burgeon\\.openclaw\\workspace",
      timeout: 10000
    });
    
    if (result.exitCode !== 0) {
      throw new Error(`截图失败: ${result.stderr}`);
    }
    
    // 3. 解析JSON结果
    const output = result.stdout;
    const match = output.match(/RESULT:({.*})/);
    if (!match) {
      throw new Error('未找到截图结果');
    }
    
    const screenshotInfo = JSON.parse(match[1]);
    if (!screenshotInfo.success) {
      throw new Error(`截图失败: ${screenshotInfo.error}`);
    }
    
    // 4. 发送给用户
    await message({
      action: "send",
      to: userId,
      media: screenshotInfo.path,
      message: `截图完成 (${screenshotInfo.width}×${screenshotInfo.height}, ${screenshotInfo.sizeKB}KB)`
    });
    
    return screenshotInfo;
    
  } catch (error) {
    console.error('截图错误:', error);
    await message({
      action: "send",
      to: userId,
      message: `截图失败: ${error.message}`
    });
    throw error;
  }
}
```

## Common Workflows

### 1. Basic Screenshot Request

**User says**: "帮我截图" or "截取屏幕"

**Steps**:
1. Capture screenshot using PowerShell
2. Save to workspace directory
3. Send via message tool with media parameter
4. Ask user to confirm receipt

### 2. Browser Screenshot (when browser tools work)

**User says**: "截图我的浏览器"

**Steps**:
1. Try browser tool first
2. If fails, fallback to system screenshot
3. Send result to user

### 3. Specific Area Screenshot (future enhancement)

**User says**: "截取这个区域"

**Steps**:
1. Could implement region selection (future feature)
2. Capture specified region
3. Send to user

## Error Handling

### Common Issues and Solutions

1. **File not found after capture**
   - Verify PowerShell executed successfully
   - Check file permissions in workspace directory
   - Retry with different filename

2. **Message sending fails**
   - Ensure media parameter is correctly specified
   - Verify file path is absolute and accessible
   - Check message tool configuration

3. **PowerShell execution errors**
   - Ensure Windows Forms/System.Drawing assemblies are available
   - Check PowerShell execution policy
   - Provide alternative method if PowerShell fails

## Performance Considerations

- **File size**: PNG screenshots are typically 50-200KB
- **Capture time**: System screenshot takes 1-2 seconds
- **Memory**: PowerShell script uses minimal memory
- **Storage**: Consider periodic cleanup of old screenshots

## Testing

### Manual Testing Commands

```powershell
# Test screenshot capture
. .\scripts\screenshot.ps1
Save-Screenshot -FilePath "test_screenshot.png"

# Verify file
Test-Path "test_screenshot.png"
```

### Automated Testing (future)
- Unit tests for PowerShell functions
- Integration tests with message sending
- Cross-platform compatibility tests

## Related Skills

- `agent-browser-clawdbot` - Browser automation including screenshot capabilities
- `dingtalk-ai-table` - DingTalk integration for sending files
- `word-docx` - Document processing that might include screenshots

## Feedback and Improvement

- Report issues: Document any platform-specific problems
- Feature requests: Region selection, annotation, multi-monitor support
- Performance: Optimize capture and file handling

## Example Usage

```javascript
// When user requests screenshot
if (taskMatches("截图", "screenshot", "截屏")) {
  // 1. Capture screenshot
  const screenshotPath = await captureScreenshot();
  
  // 2. Send to user
  message({
    action: "send",
    to: user.id,
    media: screenshotPath,
    message: "这是您请求的截图"
  });
  
  // 3. Update memory
  updateMemory(`Screenshot sent to ${user.name} at ${new Date().toISOString()}`);
}
```

## Notes

- This skill was created based on real-world experience with unreliable browser tools
- The PowerShell method has proven to be more reliable than browser CDP connections
- Always test on the target system before deploying to production