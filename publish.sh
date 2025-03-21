#!/bin/bash
set -e

# 获取版本
CURRENT_VERSION=$(grep '^version' Cargo.toml | cut -d '"' -f 2)

# 检测当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 推送代码到 GitHub
echo "🚀 推送代码到 GitHub..."
git push -u origin $CURRENT_BRANCH

# 查看是否已有该标签
if git tag | grep -q "v$CURRENT_VERSION"; then
  echo "⚠️ 标签 v$CURRENT_VERSION 已存在"
  
  read -p "是否强制更新此标签? (y/n): " choice
  if [ "$choice" == "y" ]; then
    git tag -d "v$CURRENT_VERSION"
    git push origin :refs/tags/v$CURRENT_VERSION
  else
    exit 0
  fi
fi

# 创建版本标签
echo "📝 创建版本标签 v$CURRENT_VERSION..."
git tag "v$CURRENT_VERSION"

# 推送标签到 GitHub
echo "🚀 推送标签，触发 GitHub Actions 构建发布..."
git push origin "v$CURRENT_VERSION"

echo "✅ 发布流程已启动！"
echo "查看进度: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git.*/\1/')/actions" 