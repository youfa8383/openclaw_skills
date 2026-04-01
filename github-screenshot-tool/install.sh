#!/bin/bash
# screenshot-tool 安装脚本

set -e

SKILL_NAME="screenshot-tool"
SKILL_VERSION="1.2.0"
INSTALL_DIR="${HOME}/.openclaw/workspace/skills/${SKILL_NAME}"

echo "📸 安装 OpenClaw Screenshot Tool v${SKILL_VERSION}"
echo "=========================================="

# 检查OpenClaw目录
if [ ! -d "${HOME}/.openclaw" ]; then
    echo "❌ 未找到OpenClaw目录，请先安装OpenClaw"
    exit 1
fi

# 创建技能目录
echo "📁 创建技能目录: ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"

# 复制文件
echo "📋 复制技能文件..."
cp -r ./* "${INSTALL_DIR}/" 2>/dev/null || true

# 设置权限
echo "🔧 设置脚本权限..."
chmod +x "${INSTALL_DIR}/scripts/"*.ps1 2>/dev/null || true
chmod +x "${INSTALL_DIR}/scripts/"*.sh 2>/dev/null || true

# 验证安装
if [ -f "${INSTALL_DIR}/SKILL.md" ]; then
    echo "✅ 安装成功！"
    echo ""
    echo "📋 技能信息:"
    echo "   名称: Screenshot Tool"
    echo "   版本: ${SKILL_VERSION}"
    echo "   路径: ${INSTALL_DIR}"
    echo "   脚本: ${INSTALL_DIR}/scripts/screenshot_simple.ps1"
    echo ""
    echo "🚀 使用方法:"
    echo "   1. 在OpenClaw会话中调用截图功能"
    echo "   2. 或直接运行: powershell -File \"${INSTALL_DIR}/scripts/screenshot_simple.ps1\""
    echo ""
    echo "📖 详细文档: ${INSTALL_DIR}/SKILL.md"
else
    echo "❌ 安装失败，请检查文件权限"
    exit 1
fi