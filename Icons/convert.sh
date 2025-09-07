#!/bin/bash -e
# 图标转换脚本 - 为 ZenTomato 项目生成各种尺寸的图标
ASSETS_PATH=../ZenTomato/Assets.xcassets
APPICON_SRC=ZenTomato.png
APPICON_ICONSET=${ASSETS_PATH}/AppIcon.appiconset
BARICON_SRC=tomato-filled.png
BARICON_ICONSET_IDLE=${ASSETS_PATH}/BarIconIdle.imageset

# 检查 ImageMagick 是否安装
if ! command -v magick &> /dev/null; then
    echo "错误: ImageMagick 未安装。请运行: brew install imagemagick"
    exit 1
fi

CONVERT="magick -verbose -background none"

# 创建必要的目录
mkdir -p ${APPICON_ICONSET}
mkdir -p ${BARICON_ICONSET_IDLE}

# 显示使用说明
show_usage() {
    echo "使用方法: $0 [appicon|baricon|all]"
    echo "  appicon - 生成应用图标"
    echo "  baricon - 生成菜单栏图标"
    echo "  all     - 生成所有图标 (默认)"
    echo ""
}

# 检查源文件是否存在
check_source_files() {
    if [ ! -f "${APPICON_SRC}" ]; then
        echo "错误: 找不到应用图标源文件: ${APPICON_SRC}"
        exit 1
    fi
    if [ ! -f "${BARICON_SRC}" ]; then
        echo "错误: 找不到菜单栏图标源文件: ${BARICON_SRC}"
        exit 1
    fi
}

# 生成带圆角的图标（遵循比例：radius = size * 0.2237）
# 说明：macOS 不会自动为 App 图标加圆角，因此在素材层面应用圆角蒙版。
# 该比例已在项目内确认（Confirmed via 寸止），可满足 Big Sur 风格的视觉一致性。
render_appicon_with_rounded_corners() {
    local SIZE=$1
    local DEST=$2
    # 计算圆角半径，向下取整以避免越界
    local RADIUS=$(awk "BEGIN { printf \"%d\", ${SIZE} * 0.2237 }")
    local MAX=$((SIZE - 1))

    ${CONVERT} ${APPICON_SRC} -resize "!${SIZE}x${SIZE}" +repage -alpha set \
        \( -size ${SIZE}x${SIZE} xc:none -fill white -draw "roundrectangle 0,0 ${MAX},${MAX} ${RADIUS},${RADIUS}" \) \
        -compose CopyOpacity -composite ${DEST}
}

# 生成应用图标
generate_appicon() {
    echo "正在生成应用图标..."
    check_source_files
    render_appicon_with_rounded_corners 16   ${APPICON_ICONSET}/icon_16x16.png
    render_appicon_with_rounded_corners 32   ${APPICON_ICONSET}/icon_16x16@2x.png
    render_appicon_with_rounded_corners 32   ${APPICON_ICONSET}/icon_32x32.png
    render_appicon_with_rounded_corners 64   ${APPICON_ICONSET}/icon_32x32@2x.png
    render_appicon_with_rounded_corners 128  ${APPICON_ICONSET}/icon_128x128.png
    render_appicon_with_rounded_corners 256  ${APPICON_ICONSET}/icon_128x128@2x.png
    render_appicon_with_rounded_corners 256  ${APPICON_ICONSET}/icon_256x256.png
    render_appicon_with_rounded_corners 512  ${APPICON_ICONSET}/icon_256x256@2x.png
    render_appicon_with_rounded_corners 512  ${APPICON_ICONSET}/icon_512x512.png
    render_appicon_with_rounded_corners 1024 ${APPICON_ICONSET}/icon_512x512@2x.png
    echo "应用图标生成完成！"
}

# 生成菜单栏图标
generate_baricon() {
    echo "正在生成菜单栏图标..."
    check_source_files

    # 生成空闲状态的菜单栏图标（只有番茄图标，没有文字）
    for SCALE in $(seq 1 3); do
        IMAGE_SIZE="!$((16*SCALE))x$((16*SCALE))"
        SCALE_NAME="@${SCALE}x"
        if [ ${SCALE} -eq 1 ]; then
            SCALE_NAME=""
        fi
        DEST_NAME="${BARICON_ICONSET_IDLE}/icon_16x16${SCALE_NAME}.png"
        ${CONVERT} ${BARICON_SRC} -resize "${IMAGE_SIZE}" +repage ${DEST_NAME}
    done
    echo "菜单栏图标生成完成！"
}

# 主逻辑
case "${1:-all}" in
    "appicon")
        generate_appicon
        ;;
    "baricon")
        generate_baricon
        ;;
    "all")
        generate_appicon
        generate_baricon
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

echo "所有图标转换完成！"
