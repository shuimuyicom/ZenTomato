#!/bin/bash

# ZenTomato 清理和首次安装测试脚本
# 用于清理所有缓存并模拟首次安装体验

set -e  # 遇到错误立即退出

echo "🧹 开始清理 ZenTomato 应用和构建缓存..."

# 1. 停止所有相关进程
echo "📱 停止应用进程..."
pkill -f ZenTomato || true

# 2. 清理构建缓存
echo "🗂️  清理 Xcode 构建缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ZenTomato-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/

# 3. 清理应用数据和设置
echo "⚙️  清理应用用户数据..."
# 清理应用偏好设置
defaults delete com.shuimuyi.ZenTomato 2>/dev/null || true

# 清理应用支持文件
rm -rf ~/Library/Application\ Support/ZenTomato/ 2>/dev/null || true

# 清理应用缓存
rm -rf ~/Library/Caches/com.shuimuyi.ZenTomato/ 2>/dev/null || true

# 4. 重置通知权限（需要重启通知中心服务）
echo "🔔 重置通知权限..."
# 删除通知数据库中的应用记录
sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "DELETE FROM access WHERE client='com.shuimuyi.ZenTomato';" 2>/dev/null || true

# 重启通知中心（可选，需要管理员权限）
# sudo killall usernoted 2>/dev/null || true

# 5. 清理 Launch Services 注册
echo "🚀 清理 Launch Services..."
/System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister -kill -r -domain local -domain system -domain user

# 6. 删除已安装的应用（如果存在）
echo "🗑️  删除已安装的应用..."
rm -rf /Applications/ZenTomato.app 2>/dev/null || true
rm -rf ~/Applications/ZenTomato.app 2>/dev/null || true

# 7. 清理 Xcode 项目缓存
echo "🔧 清理项目缓存..."
cd "$(dirname "$0")"
rm -rf .build/ 2>/dev/null || true
rm -rf build/ 2>/dev/null || true

# 8. Clean Build Folder
echo "🧽 执行 Xcode Clean Build..."
xcodebuild -project ZenTomato.xcodeproj -scheme ZenTomato clean

# 9. 重新构建
echo "🔨 重新构建应用..."
xcodebuild -project ZenTomato.xcodeproj -scheme ZenTomato -configuration Debug build

# 10. 启动应用进行测试
echo "🚀 启动应用进行首次安装测试..."
BUILD_PATH=$(find ~/Library/Developer/Xcode/DerivedData/ZenTomato-*/Build/Products/Debug -name "ZenTomato.app" 2>/dev/null | head -1)

if [ -n "$BUILD_PATH" ]; then
    echo "✅ 应用构建成功，路径: $BUILD_PATH"
    echo "🎯 启动应用..."
    open "$BUILD_PATH"
    
    echo ""
    echo "🎉 清理和重新构建完成！"
    echo ""
    echo "📋 测试检查清单："
    echo "  ✅ 1. 应用应该会请求通知权限（首次运行）"
    echo "  ✅ 2. 检查通知样式是否为横幅模式"
    echo "  ✅ 3. 测试计时器完成后的通知显示"
    echo "  ✅ 4. 验证通知在屏幕顶部以横幅形式显示"
    echo ""
    echo "🔍 如需检查通知设置："
    echo "  系统设置 > 通知 > ZenTomato"
    echo ""
else
    echo "❌ 构建失败，未找到应用文件"
    exit 1
fi
