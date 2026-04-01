# 📸 OpenClaw Screenshot Tool

[![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-blue)](https://openclaw.ai)
[![Version](https://img.shields.io/badge/version-1.2.0-green)](https://github.com/yourusername/openclaw-screenshot-tool/releases)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-blue)](https://www.microsoft.com/windows)

**可靠的开源截图工具** - 为OpenClaw设计的Windows截图技能，经过实际测试验证。

## 🎯 功能特点

- ✅ **可靠截图**: 使用1920×1080固定分辨率，避免系统API问题
- ✅ **简单易用**: 一键截图并发送到消息平台
- ✅ **错误处理**: 完整的异常捕获和JSON输出
- ✅ **跨会话**: 可在任何OpenClaw会话中调用
- ✅ **已验证**: 实际测试通过，用户确认正确

## 📦 快速开始

### 安装方法

#### 方法1: 手动安装 (推荐)
```bash
# 克隆仓库
git clone https://github.com/yourusername/openclaw-screenshot-tool.git

# 复制到OpenClaw技能目录
cp -r openclaw-screenshot-tool ~/.openclaw/workspace/skills/screenshot-tool
```

#### 方法2: 使用安装脚本
```bash
# 运行安装脚本
chmod +x install.sh
./install.sh
```

#### 方法3: 从ZIP安装
1. 下载最新的 [Release](https://github.com/yourusername/openclaw-screenshot-tool/releases)
2. 解压到 `~/.openclaw/workspace/skills/screenshot-tool/`

### 验证安装
```powershell
# 测试技能是否工作
cd ~/.openclaw/workspace/skills/screenshot-tool
powershell -ExecutionPolicy Bypass -File scripts/screenshot_simple.ps1
```

## 🚀 使用方法

### 在OpenClaw中调用
```javascript
// 完整示例 - 截图并发送
async function captureAndSendScreenshot(userId) {
  try {
    // 生成输出路径
    const timestamp = new Date().toISOString().replace(/[:.]/g, '_');
    const screenshotPath = `C:\\screenshots\\screenshot_${timestamp}.png`;
    
    // 执行截图
    const result = await exec({
      command: `powershell -ExecutionPolicy Bypass -File "scripts/screenshot_simple.ps1" -OutputPath "${screenshotPath}"`,
      workdir: "~/.openclaw/workspace/skills/screenshot-tool",
      timeout: 10000
    });
    
    // 解析结果
    const output = result.stdout;
    const match = output.match(/RESULT:({.*})/);
    if (!match) throw new Error('未找到截图结果');
    
    const screenshotInfo = JSON.parse(match[1]);
    if (!screenshotInfo.success) throw new Error(screenshotInfo.error);
    
    // 发送给用户
    await message({
      action: "send",
      to: userId,
      media: screenshotInfo.path,
      message: `截图完成 (${screenshotInfo.width}×${screenshotInfo.height}, ${screenshotInfo.sizeKB}KB)`
    });
    
    return screenshotInfo;
    
  } catch (error) {
    console.error('截图错误:', error);
    throw error;
  }
}
```

### 直接使用脚本
```powershell
# 基本用法
powershell -File "scripts/screenshot_simple.ps1"

# 指定输出路径
powershell -File "scripts/screenshot_simple.ps1" -OutputPath "C:\screenshots\my.png"

# 查看帮助
powershell -File "scripts/screenshot_simple.ps1" -?
```

## 📁 项目结构

```
openclaw-screenshot-tool/
├── .gitignore
├── LICENSE
├── README.md                 # 本文件
├── SKILL.md                  # OpenClaw技能规范
├── install.sh                # 安装脚本
├── scripts/
│   ├── screenshot_simple.ps1 # 主脚本 (推荐)
│   ├── screenshot.ps1        # 原始脚本 (有问题的版本)
│   └── test-screenshot.ps1   # 测试脚本
└── references/
    └── usage-example.md      # 使用示例
```

## 🔧 技术细节

### 修复的问题
- **v1.0.0问题**: `System.Windows.Forms.Screen` 无法正确获取分辨率
- **v1.2.0修复**: 使用固定的1920×1080分辨率，移除问题依赖

### 分辨率选择
经过实际测试验证：
- 2560×1440: 太大，有空白区域
- 1920×1080: ✅ 正确，完整截图
- 1280×720: 太小，不完整

### 输出格式
脚本输出JSON格式结果：
```json
{
  "success": true,
  "path": "C:\\screenshots\\screenshot_2026-04-01_1413.png",
  "sizeKB": 269.61,
  "width": 1920,
  "height": 1080,
  "created": "2026-04-01 14:13:17"
}
```

## 📖 文档

- [技能规范](SKILL.md) - OpenClaw技能详细说明
- [使用示例](references/usage-example.md) - 完整代码示例
- [测试脚本](scripts/test-screenshot.ps1) - 验证安装

## 🤝 贡献指南

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 开发要求
- 所有脚本必须通过测试
- 更新版本号和相关文档
- 遵循现有代码风格

## 🐛 问题反馈

请使用 [GitHub Issues](https://github.com/yourusername/openclaw-screenshot-tool/issues) 报告问题。

**报告问题时请提供：**
1. 操作系统版本
2. PowerShell版本 (`$PSVersionTable.PSVersion`)
3. 错误信息截图
4. 脚本输出内容

## 📄 许可证

本项目基于 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [OpenClaw](https://openclaw.ai) - 优秀的AI助手平台
- 所有测试用户和贡献者
- 开源社区的支持

## 📞 联系方式

- **作者**: 梁津永
- **GitHub**: [@yourusername](https://github.com/yourusername)
- **问题**: [Issues](https://github.com/yourusername/openclaw-screenshot-tool/issues)

---
*最后更新: 2026-04-01*  
*版本: 1.2.0*