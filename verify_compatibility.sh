#!/bin/bash

# verify_compatibility.sh
# 自动化测试脚本：验证项目是否兼容 analyzer ^5.13.0 和 ^6.4.1

set -e # 遇到错误立即退出

echo "🔍 开始兼容性测试..."

# 1. 测试 Analyzer 5.x
echo "--------------------------------------------------------"
echo "🛠️  [Scene 1] 测试 Analyzer 5.x"
echo "--------------------------------------------------------"

# 强制使用 analyzer 5.x
# 注意：dart_style ^2.3.7 依赖 analyzer 6.x，所以测试 5.x 时需要移除或降级
echo "Removing dart_style constraint for Analyzer 5.x compatibility..."
fvm flutter pub remove dart_style || true

fvm flutter pub add "analyzer:>=5.13.0 <6.0.0"

echo "⬇️  安装依赖..."
fvm flutter pub get

echo "🧱 运行构建..."
# 清理旧的构建产物以确保干净的测试环境
fvm dart run build_runner clean || true
fvm dart run build_runner build --delete-conflicting-outputs

echo "✅ Analyzer 5.x 测试通过！"


# 2. 测试 Analyzer 6.x
echo "--------------------------------------------------------"
echo "🛠️  [Scene 2] 测试 Analyzer 6.x"
echo "--------------------------------------------------------"

# 强制使用 analyzer 6.x
fvm flutter pub add "analyzer:^6.0.0"

# 必须添加 dart_style 以修复 analyzer 6.x 的构建问题
echo "Adding dart_style constraint for Analyzer 6.x compatibility..."
fvm flutter pub add "dart_style:^2.3.7" --dev

echo "⬇️  安装依赖..."
fvm flutter pub get

echo "🧱 运行构建..."
fvm dart run build_runner clean || true
fvm dart run build_runner build --delete-conflicting-outputs

echo "✅ Analyzer 6.x 测试通过！"

# 3. 恢复原始配置 (可选，或者建议用户 discard changes)
echo "--------------------------------------------------------"
echo "🎉 所有测试完成！请检查 pubspec.yaml 并根据需要还原开发依赖。"
echo "注意：脚本修改了 dev_dependencies 中的 analyzer 版本，请在提交前还原。"
echo "--------------------------------------------------------"
