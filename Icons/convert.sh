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
## 简化策略：仅进行尺寸裁切(缩放到目标尺寸)，不再应用圆角蒙版或内缩。

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

# 校验输出 PNG 尺寸是否与目标一致
validate_png_size() {
    local FILE=$1
    local W=$(magick identify -format "%w" "$FILE")
    local H=$(magick identify -format "%h" "$FILE")
    if [ "$W" != "$2" ] || [ "$H" != "$3" ]; then
        echo "错误: 生成文件尺寸不匹配: $FILE 实际 ${W}x${H}, 期望 ${2}x${3}" >&2
        exit 1
    fi
}

# 生成应用图标（仅尺寸裁切/缩放）
render_appicon_plain() {
    local SIZE=$1
    local DEST=$2
    ${CONVERT} ${APPICON_SRC} -resize "!${SIZE}x${SIZE}" +repage -strip ${DEST}
    validate_png_size "${DEST}" "${SIZE}" "${SIZE}"
}

# 生成应用图标
generate_appicon() {
    echo "正在生成应用图标..."
    check_source_files
    render_appicon_plain 16   ${APPICON_ICONSET}/icon_16x16.png
    render_appicon_plain 32   ${APPICON_ICONSET}/icon_16x16@2x.png
    render_appicon_plain 32   ${APPICON_ICONSET}/icon_32x32.png
    render_appicon_plain 64   ${APPICON_ICONSET}/icon_32x32@2x.png
    render_appicon_plain 128  ${APPICON_ICONSET}/icon_128x128.png
    render_appicon_plain 256  ${APPICON_ICONSET}/icon_128x128@2x.png
    render_appicon_plain 256  ${APPICON_ICONSET}/icon_256x256.png
    render_appicon_plain 512  ${APPICON_ICONSET}/icon_256x256@2x.png
    render_appicon_plain 512  ${APPICON_ICONSET}/icon_512x512.png
    render_appicon_plain 1024 ${APPICON_ICONSET}/icon_512x512@2x.png
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
