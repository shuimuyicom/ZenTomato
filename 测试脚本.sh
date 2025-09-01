#!/bin/bash
# ZenTomato 左上角图标替换测试脚本

set -e  # 遇到错误立即退出

echo "🍅 ZenTomato 左上角图标替换测试脚本"
echo "========================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_DIR="/Users/shuimuyi/Documents/ZenTomato"
BUILD_DIR="/Users/shuimuyi/Library/Developer/Xcode/DerivedData/ZenTomato-agkbbmjpilrqmyhedwkpkybdnzkt/Build/Products/Debug"
APP_PATH="$BUILD_DIR/ZenTomato.app"

# 检查项目目录
echo -e "${BLUE}📁 检查项目目录...${NC}"
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ 项目目录不存在: $PROJECT_DIR${NC}"
    exit 1
fi
echo -e "${GREEN}✅ 项目目录存在${NC}"

# 检查关键文件
echo -e "${BLUE}📄 检查关键文件...${NC}"
MAIN_VIEW="$PROJECT_DIR/ZenTomato/Views/MainView.swift"
if [ ! -f "$MAIN_VIEW" ]; then
    echo -e "${RED}❌ MainView.swift 文件不存在${NC}"
    exit 1
fi
echo -e "${GREEN}✅ MainView.swift 文件存在${NC}"

# 检查图标资源
echo -e "${BLUE}🖼️  检查图标资源...${NC}"
APPICON_DIR="$PROJECT_DIR/ZenTomato/Assets.xcassets/AppIcon.appiconset"
if [ ! -d "$APPICON_DIR" ]; then
    echo -e "${RED}❌ AppIcon 资源目录不存在${NC}"
    exit 1
fi
echo -e "${GREEN}✅ AppIcon 资源目录存在${NC}"

# 检查代码修改
echo -e "${BLUE}🔍 检查代码修改...${NC}"
if grep -q "NSImage(named: \"AppIcon\")" "$MAIN_VIEW"; then
    echo -e "${GREEN}✅ 发现 AppIcon 引用${NC}"
else
    echo -e "${RED}❌ 未找到 AppIcon 引用${NC}"
    exit 1
fi

if grep -q "RoundedRectangle(cornerRadius: 28 \* 0.2237" "$MAIN_VIEW"; then
    echo -e "${GREEN}✅ 发现 macOS 标准圆角设置${NC}"
else
    echo -e "${RED}❌ 未找到标准圆角设置${NC}"
    exit 1
fi

if grep -q "style: \.continuous" "$MAIN_VIEW"; then
    echo -e "${GREEN}✅ 发现连续曲线样式${NC}"
else
    echo -e "${RED}❌ 未找到连续曲线样式${NC}"
    exit 1
fi

# 编译测试
echo -e "${BLUE}🔨 开始编译测试...${NC}"
cd "$PROJECT_DIR"

echo -e "${YELLOW}正在清理构建缓存...${NC}"
xcodebuild -project ZenTomato.xcodeproj -scheme ZenTomato -configuration Debug clean > /dev/null 2>&1

echo -e "${YELLOW}正在编译项目...${NC}"
if xcodebuild -project ZenTomato.xcodeproj -scheme ZenTomato -configuration Debug build > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 编译成功${NC}"
else
    echo -e "${RED}❌ 编译失败${NC}"
    exit 1
fi

# 检查构建产物
echo -e "${BLUE}📦 检查构建产物...${NC}"
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ 应用程序包不存在${NC}"
    exit 1
fi
echo -e "${GREEN}✅ 应用程序包存在${NC}"

# 检查应用图标资源
echo -e "${BLUE}🎨 检查应用图标资源...${NC}"
ICON_FILE="$APP_PATH/Contents/Resources/AppIcon.icns"
if [ ! -f "$ICON_FILE" ]; then
    echo -e "${RED}❌ 应用图标文件不存在${NC}"
    exit 1
fi
echo -e "${GREEN}✅ 应用图标文件存在${NC}"

# 启动应用测试
echo -e "${BLUE}🚀 启动应用进行测试...${NC}"
echo -e "${YELLOW}正在启动 ZenTomato...${NC}"

# 杀死可能存在的进程
pkill -f "ZenTomato" 2>/dev/null || true

# 启动应用
open "$APP_PATH" &
APP_PID=$!

# 等待应用启动
sleep 3

# 检查应用是否正在运行
if pgrep -f "ZenTomato" > /dev/null; then
    echo -e "${GREEN}✅ 应用启动成功${NC}"
else
    echo -e "${RED}❌ 应用启动失败${NC}"
    exit 1
fi

# 功能测试提示
echo -e "${BLUE}🧪 手动测试项目:${NC}"
echo "1. 检查左上角是否显示应用主图标"
echo "2. 验证图标是否具有适当的圆角"
echo "3. 确认图标尺寸和位置是否合适"
echo "4. 测试图标在不同主题下的显示效果"
echo "5. 验证图标的阴影效果"

echo ""
echo -e "${GREEN}🎉 所有自动化测试通过！${NC}"
echo -e "${YELLOW}请手动验证应用界面中的图标效果${NC}"
echo ""
echo "按任意键关闭应用并结束测试..."
read -n 1 -s

# 关闭应用
pkill -f "ZenTomato" 2>/dev/null || true

echo -e "${GREEN}✅ 测试完成${NC}"
