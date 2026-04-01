#!/bin/bash
# GitHub仓库初始化脚本

echo "🚀 OpenClaw Screenshot Tool - GitHub仓库初始化"
echo "=============================================="

# 检查是否在git仓库中
if [ ! -d ".git" ]; then
    echo "📦 初始化Git仓库..."
    git init
    git add .
    git commit -m "Initial commit: OpenClaw Screenshot Tool v1.2.0"
    echo "✅ Git仓库初始化完成"
else
    echo "📦 Git仓库已存在，跳过初始化"
fi

echo ""
echo "📋 下一步操作："
echo ""
echo "1. 在GitHub创建新仓库："
echo "   - 访问 https://github.com/new"
echo "   - 仓库名: openclaw-screenshot-tool"
echo "   - 描述: Reliable screenshot tool for OpenClaw"
echo "   - 选择: Public (公开)"
echo "   - 不要初始化README (我们已经有了)"
echo ""
echo "2. 添加远程仓库并推送："
echo "   git remote add origin https://github.com/YOUR_USERNAME/openclaw-screenshot-tool.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. 创建第一个Release："
echo "   - 访问 https://github.com/YOUR_USERNAME/openclaw-screenshot-tool/releases/new"
echo "   - Tag: v1.2.0"
echo "   - 标题: OpenClaw Screenshot Tool v1.2.0"
echo "   - 描述: 可靠的开源截图工具，经过实际测试验证"
echo "   - 上传: screenshot-tool-v1.2.0.zip (可选)"
echo ""
echo "4. 添加徽章 (可选)："
echo "   在README.md中更新仓库链接："
echo "   - 将 'yourusername' 替换为你的GitHub用户名"
echo "   - 将 'YOUR_USERNAME' 替换为你的GitHub用户名"
echo ""
echo "🎉 完成！你的技能现在可以在GitHub上分享了。"

# 显示当前文件结构
echo ""
echo "📁 当前文件结构："
find . -type f -name "*.md" -o -name "*.ps1" -o -name "*.sh" | sort | sed 's|^\./||'