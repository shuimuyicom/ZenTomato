#!/bin/bash

# 关于页面功能测试脚本
# 测试新实现的关于页面功能

echo "🍅 ZenTomato 关于页面功能测试"
echo "================================"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数器
TOTAL_TESTS=0
PASSED_TESTS=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${YELLOW}测试 $TOTAL_TESTS: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ 失败${NC}"
    fi
}

# 检查文件是否存在
check_file_exists() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        return 0
    else
        return 1
    fi
}

# 检查代码中是否包含特定内容
check_code_contains() {
    local file_path="$1"
    local search_pattern="$2"
    if grep -q "$search_pattern" "$file_path"; then
        return 0
    else
        return 1
    fi
}

echo "开始测试..."

# 测试1: 检查AboutView.swift文件是否存在
run_test "AboutView.swift 文件存在" "check_file_exists 'ZenTomato/Views/AboutView.swift'"

# 测试2: 检查AboutWindowManager.swift文件是否存在
run_test "AboutWindowManager.swift 文件存在" "check_file_exists 'ZenTomato/ViewModels/AboutWindowManager.swift'"

# 测试3: 检查AboutView中是否包含协议链接
run_test "AboutView 包含服务协议链接" "check_code_contains 'ZenTomato/Views/AboutView.swift' 'zentomato-terms-of-service'"

# 测试4: 检查AboutView中是否包含隐私协议链接
run_test "AboutView 包含隐私协议链接" "check_code_contains 'ZenTomato/Views/AboutView.swift' 'zentomato-privacy-policy'"

# 测试5: 检查AboutView中是否包含版权声明
run_test "AboutView 包含版权声明" "check_code_contains 'ZenTomato/Views/AboutView.swift' '©️水木易'"

# 测试6: 检查AboutView中是否使用了应用图标
run_test "AboutView 使用应用图标" "check_code_contains 'ZenTomato/Views/AboutView.swift' 'AppIcon'"

# 测试7: 检查AboutView中图标是否使用了圆角样式
run_test "AboutView 图标使用圆角样式" "check_code_contains 'ZenTomato/Views/AboutView.swift' 'RoundedRectangle.*cornerRadius.*0.2237'"

# 测试8: 检查MainView是否调用了新的关于窗口管理器
run_test "MainView 调用 AboutWindowManager" "check_code_contains 'ZenTomato/Views/MainView.swift' 'AboutWindowManager.shared.showAboutWindow'"

# 测试9: 检查AboutWindowManager是否继承自NSObject
run_test "AboutWindowManager 继承 NSObject" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'class AboutWindowManager: NSObject'"

# 测试10: 检查AboutWindowManager是否实现了NSWindowDelegate
run_test "AboutWindowManager 实现 NSWindowDelegate" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'NSWindowDelegate'"

# 测试11: 检查AboutWindowManager是否有窗口重复显示处理逻辑
run_test "AboutWindowManager 处理窗口重复显示" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'window.isVisible'"

# 测试12: 检查窗口尺寸是否正确设置
run_test "窗口尺寸设置正确" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'width: 450, height: 380'"

# 测试13: 检查窗口样式掩码是否包含closable
run_test "窗口样式包含closable" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' '.closable'"

# 测试14: 检查窗口层级是否设置为normal
run_test "窗口层级设置为normal" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' '.normal'"

# 测试15: 检查窗口是否调用center方法
run_test "窗口调用center方法" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'center()'"

# 测试16: 检查AboutView尺寸是否更新
run_test "AboutView尺寸更新" "check_code_contains 'ZenTomato/Views/AboutView.swift' 'width: 450, height: 380'"

# 测试17: 检查showAbout方法是否调用hidePopover
run_test "showAbout调用hidePopover" "check_code_contains 'ZenTomato/Views/MainView.swift' 'menuBarManager.hidePopover()'"

# 测试18: 检查应用是否能成功编译
run_test "应用编译成功" "xcodebuild -project ZenTomato.xcodeproj -scheme ZenTomato -configuration Debug build > /dev/null 2>&1"

# 输出测试结果
echo -e "\n================================"
echo -e "测试完成！"
echo -e "总测试数: $TOTAL_TESTS"
echo -e "通过测试: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失败测试: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "\n${GREEN}🎉 所有测试通过！关于页面功能实现成功！${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  有测试失败，请检查实现。${NC}"
    exit 1
fi
