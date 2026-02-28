#!/bin/bash
# AwareWalk — App Store 截图自动化脚本
# visionOS 截图要求: 3840 x 2160 px (landscape)
#
# 使用方式:
#   1. 确保 visionOS 模拟器已启动并安装了 app
#   2. chmod +x screenshot_appstore.sh
#   3. ./screenshot_appstore.sh

set -e

APP_BUNDLE="com.jingjing.AwareWalk"
OUTPUT_DIR="$(pwd)/AppStoreScreenshots"

# 获取正在运行的 visionOS 模拟器 UUID
SIM_UUID=$(xcrun simctl list devices booted -j | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data['devices'].items():
    if 'xrOS' in runtime or 'visionOS' in runtime:
        for d in devices:
            if d['state'] == 'Booted':
                print(d['udid'])
                sys.exit(0)
print('NONE')
")

if [ "$SIM_UUID" = "NONE" ]; then
    echo "❌ 没有找到已启动的 visionOS 模拟器"
    echo "   请先启动: xcrun simctl boot 'Apple Vision Pro'"
    exit 1
fi

echo "✅ 找到模拟器: $SIM_UUID"

mkdir -p "$OUTPUT_DIR/en" "$OUTPUT_DIR/ja" "$OUTPUT_DIR/ko"

echo "📸 开始截图..."

take_screenshot() {
    local name=$1
    local lang=$2
    local delay=${3:-2}
    
    sleep "$delay"
    xcrun simctl io "$SIM_UUID" screenshot "$OUTPUT_DIR/$lang/${name}.png"
    echo "  ✅ $lang/$name.png"
}

echo "🚀 启动 AwareWalk..."
xcrun simctl launch "$SIM_UUID" "$APP_BUNDLE"
sleep 3

echo ""
echo "📷 English Screenshots"

# 1. 启动页 — 守护之眼按钮
take_screenshot "01_launch" "en" 3

# 2. HUD 激活后
echo "⏸  请手动点击「Activate HUD」按钮，然后等待截图..."
take_screenshot "02_hud_active" "en" 8

# 3. 主题画廊
echo "⏸  请手动打开 Theme Gallery..."
take_screenshot "03_themes" "en" 5

# 4. 设置页面
echo "⏸  请手动打开 Settings..."
take_screenshot "04_settings" "en" 5

echo ""
echo "================================================"
echo "✅ 截图完成！保存在: $OUTPUT_DIR"
echo ""
echo "📋 visionOS App Store 要求:"
echo "   - 尺寸: 3840 x 2160 px"
echo "   - 格式: PNG 或 JPEG"
echo "   - 数量: 至少 3 张, 最多 10 张"
echo ""
echo "💡 提示: 日文和韩文截图需要切换模拟器语言后重新运行"
echo "   Settings > General > Language & Region"
echo "================================================"
