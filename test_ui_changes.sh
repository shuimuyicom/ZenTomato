#!/bin/bash

# ZenTomato UI 变更测试脚本
# 测试进度条删除和文案修改的效果

echo "🧪 ZenTomato UI 变更测试开始..."
echo "=================================="

# 检查项目目录
if [ ! -d "ZenTomato.xcodeproj" ]; then
    echo "❌ 错误: 未找到 ZenTomato.xcodeproj 项目文件"
    exit 1
fi

echo "✅ 项目文件检查通过"

# 检查 MainView.swift 文件是否存在
if [ ! -f "ZenTomato/Views/MainView.swift" ]; then
    echo "❌ 错误: 未找到 MainView.swift 文件"
    exit 1
fi

echo "✅ MainView.swift 文件存在"

# 测试1: 检查进度条代码是否已删除
echo ""
echo "🔍 测试1: 检查进度条代码删除情况"
echo "-----------------------------------"

if grep -q "GeometryReader.*geometry" ZenTomato/Views/MainView.swift; then
    echo "⚠️  警告: 仍然存在 GeometryReader 代码，可能进度条未完全删除"
else
    echo "✅ 进度条相关的 GeometryReader 代码已删除"
fi

if grep -q "RoundedRectangle.*cornerRadius.*2" ZenTomato/Views/MainView.swift; then
    echo "⚠️  警告: 仍然存在进度条的 RoundedRectangle 代码"
else
    echo "✅ 进度条的 RoundedRectangle 代码已删除"
fi

# 测试2: 检查文案是否已更新
echo ""
echo "🔍 测试2: 检查状态文案更新情况"
echo "-----------------------------------"

if grep -q "已完成.*次专注" ZenTomato/Views/MainView.swift; then
    echo "✅ 新文案 '已完成 X 次专注' 已应用"
else
    echo "❌ 错误: 未找到新的文案格式"
fi

if grep -q "completedCycles.*已完成" ZenTomato/Views/MainView.swift; then
    echo "⚠️  警告: 仍然存在旧的文案格式"
else
    echo "✅ 旧文案格式已清理"
fi

# 测试3: 代码语法检查
echo ""
echo "🔍 测试3: Swift 代码语法检查"
echo "-----------------------------------"

# 使用 swiftc 进行基本语法检查（如果可用）
if command -v swiftc &> /dev/null; then
    echo "正在进行 Swift 语法检查..."
    if swiftc -parse ZenTomato/Views/MainView.swift &> /dev/null; then
        echo "✅ Swift 语法检查通过"
    else
        echo "❌ Swift 语法检查失败，请检查代码"
    fi
else
    echo "⚠️  swiftc 不可用，跳过语法检查"
fi

# 测试4: 检查相关依赖是否完整
echo ""
echo "🔍 测试4: 检查代码依赖完整性"
echo "-----------------------------------"

# 检查是否还有对进度条相关属性的引用
if grep -q "\.progress" ZenTomato/Views/MainView.swift; then
    echo "⚠️  注意: 代码中仍有 .progress 属性引用，请确认是否需要"
else
    echo "✅ 无多余的进度条属性引用"
fi

# 检查 TimerEngine 相关引用是否正常
if grep -q "timerEngine\.completedCycles" ZenTomato/Views/MainView.swift; then
    echo "✅ TimerEngine.completedCycles 引用正常"
else
    echo "❌ 错误: TimerEngine.completedCycles 引用缺失"
fi

echo ""
echo "🎉 测试完成!"
echo "=================================="
echo "请运行以下命令进行完整测试:"
echo "1. 在 Xcode 中打开项目"
echo "2. 执行 Clean Build Folder (Cmd+Shift+K)"
echo "3. 构建项目 (Cmd+B)"
echo "4. 运行应用 (Cmd+R)"
echo "5. 检查界面是否符合预期"
