#!/bin/bash
set -e

# 设置变量
NAME="ip-cn-asn"
VERSION=$(grep '^version' Cargo.toml | cut -d '"' -f 2)
TARGETS=(
  "x86_64-unknown-linux-gnu"
  "x86_64-apple-darwin"
  "aarch64-apple-darwin"
)
OUTPUT_DIR="dist"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "🔧 构建 $NAME v$VERSION"

# 对每个目标平台进行编译
for target in "${TARGETS[@]}"; do
  echo "📦 为 $target 编译..."
  
  # 检查是否已安装目标平台
  if ! rustup target list | grep -q "$target installed"; then
    echo "📥 安装 $target 编译目标..."
    rustup target add "$target"
  fi
  
  # 编译
  cargo build --release --target "$target"
  
  # 创建发布压缩包
  TARGET_OUTPUT_DIR="$OUTPUT_DIR/$target"
  mkdir -p "$TARGET_OUTPUT_DIR"
  
  # 复制二进制文件和文档
  cp "target/$target/release/$NAME" "$TARGET_OUTPUT_DIR/"
  cp README.md LICENSE* "$TARGET_OUTPUT_DIR/" 2>/dev/null || true
  
  # 创建压缩包
  ARCHIVE_NAME="$NAME-$VERSION-$target.tar.gz"
  tar -czf "$OUTPUT_DIR/$ARCHIVE_NAME" -C "$OUTPUT_DIR" "$target"
  
  echo "✅ 创建完成: $ARCHIVE_NAME"
done

echo "🎉 所有版本构建完成！"
echo "�� 输出目录: $OUTPUT_DIR" 