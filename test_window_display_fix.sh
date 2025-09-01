#!/bin/bash

# ZenTomato 窗口显示问题修复测试脚本
# 测试主窗口尺寸调整和关于窗口居中显示功能

echo "🍅 ZenTomato 窗口显示问题修复测试"
echo "=================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试计数器
TOTAL_TESTS=0
PASSED_TESTS=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "测试 $TOTAL_TESTS: $test_name ... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ 失败${NC}"
    fi
}

# 检查代码内容的函数
check_code_contains() {
    local file_path="$1"
    local search_text="$2"
    
    if [ -f "$file_path" ]; then
        grep -q "$search_text" "$file_path"
    else
        return 1
    fi
}

# 检查代码不包含特定内容的函数
check_code_not_contains() {
    local file_path="$1"
    local search_text="$2"
    
    if [ -f "$file_path" ]; then
        ! grep -q "$search_text" "$file_path"
    else
        return 1
    fi
}

echo -e "${BLUE}开始测试窗口显示修复...${NC}"
echo

# 测试1: 检查MenuBarManager中popover尺寸是否已调整为380x680
run_test "主窗口popover尺寸调整为380x680" "check_code_contains 'ZenTomato/ViewModels/MenuBarManager.swift' 'width: 380, height: 680'"

# 测试2: 检查是否移除了旧的300x400尺寸设置
run_test "移除旧的300x400尺寸设置" "check_code_not_contains 'ZenTomato/ViewModels/MenuBarManager.swift' 'width: 300, height: 400'"

# 测试3: 检查MainView中的frame尺寸是否为380x680
run_test "MainView frame尺寸为380x680" "check_code_contains 'ZenTomato/Views/MainView.swift' 'frame(width: 380, height: 680)'"

# 测试4: 检查关于窗口是否实现了居中显示
run_test "关于窗口实现居中显示" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'aboutWindow?.center()'"

# 测试5: 检查关于窗口尺寸是否为450x380
run_test "关于窗口尺寸为450x380" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'width: 450, height: 380'"

# 测试6: 检查popover行为设置
run_test "popover行为设置为transient" "check_code_contains 'ZenTomato/ViewModels/MenuBarManager.swift' 'behavior = .transient'"

# 测试7: 检查popover动画设置
run_test "popover动画设置为true" "check_code_contains 'ZenTomato/ViewModels/MenuBarManager.swift' 'animates = true'"

# 测试8: 检查关于窗口样式掩码
run_test "关于窗口样式包含closable和miniaturizable" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' '.closable, .miniaturizable'"

# 测试9: 检查关于窗口层级设置
run_test "关于窗口层级设置为normal" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'level = .normal'"

# 测试10: 检查关于窗口尺寸限制
run_test "关于窗口设置了最小和最大尺寸限制" "check_code_contains 'ZenTomato/ViewModels/AboutWindowManager.swift' 'minSize = windowSize'"

# 测试11: 检查MenuBarManager中的注释说明
run_test "MenuBarManager包含尺寸调整说明注释" "check_code_contains 'ZenTomato/ViewModels/MenuBarManager.swift' '调整弹出窗口尺寸以匹配 MainView 的实际内容尺寸'"

# 测试12: 检查应用图标尺寸是否调整为40x40容器
run_test "应用图标容器尺寸调整为40x40" "check_code_contains 'ZenTomato/Views/MainView.swift' 'frame(width: 40, height: 40)'"

# 测试13: 检查应用图标内容尺寸是否调整为36x36
run_test "应用图标内容尺寸调整为36x36" "check_code_contains 'ZenTomato/Views/MainView.swift' 'frame(width: 36, height: 36)'"

# 测试14: 检查popover显示逻辑是否包含屏幕边界检查
run_test "popover显示包含屏幕边界检查" "check_code_contains 'ZenTomato/ViewModels/MenuBarManager.swift' 'screenFrame.maxX'"

# 测试15: 检查应用是否能正常编译
run_test "应用能正常编译" "xcodebuild -project ZenTomato.xcodeproj -scheme ZenTomato -configuration Debug build"

echo
echo "=================================="
echo -e "${BLUE}测试完成！${NC}"
echo -e "总测试数: ${YELLOW}$TOTAL_TESTS${NC}"
echo -e "通过测试: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失败测试: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}🎉 所有测试通过！窗口显示问题修复成功！${NC}"
    exit 0
else
    echo -e "${RED}❌ 部分测试失败，请检查修复情况${NC}"
    exit 1
fi
