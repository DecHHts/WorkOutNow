#!/bin/bash

# 创建应用图标 - 白色哑铃，黑色背景，1024x1024

ICON_PATH="/Users/christopher/heyuxuan_prjs/Xcode/WorkOutNow/WorkOutNow/Assets.xcassets/AppIcon.appiconset"

# 使用 sips 和 ImageMagick 创建图标
# 如果没有 ImageMagick，可以用 Python PIL 或者手动在 Figma/Sketch 创建

cat > /tmp/create_icon.py << 'PYTHON_SCRIPT'
from PIL import Image, ImageDraw

# 创建 1024x1024 黑色背景
size = 1024
img = Image.new('RGBA', (size, size), color='black')
draw = ImageDraw.Draw(img)

# 绘制白色哑铃图标
# 中心杠铃
bar_width = 600
bar_height = 60
bar_x = (size - bar_width) // 2
bar_y = (size - bar_height) // 2

# 绘制杠
draw.rectangle([(bar_x, bar_y), (bar_x + bar_width, bar_y + bar_height)], fill='white')

# 左侧重量盘
weight_width = 120
weight_height = 280
left_weight_x = bar_x - weight_width + 20
left_weight_y = (size - weight_height) // 2

# 绘制3层重量盘（立体效果）
for i in range(3):
    offset = i * 15
    alpha = 255 - (i * 40)
    color = (255, 255, 255, alpha)
    draw.rectangle([
        (left_weight_x - offset, left_weight_y + offset),
        (left_weight_x + weight_width - offset, left_weight_y + weight_height - offset)
    ], fill=color)

# 右侧重量盘
right_weight_x = bar_x + bar_width - 20
for i in range(3):
    offset = i * 15
    alpha = 255 - (i * 40)
    color = (255, 255, 255, alpha)
    draw.rectangle([
        (right_weight_x + offset, left_weight_y + offset),
        (right_weight_x + weight_width + offset, left_weight_y + weight_height - offset)
    ], fill=color)

# 保存标准图标
img.save('/tmp/AppIcon-1024.png')

# 创建tinted版本（单色）
tinted = Image.new('RGBA', (size, size), color=(255, 255, 255, 0))
tinted_draw = ImageDraw.Draw(tinted)
# 只绘制轮廓
tinted_draw.rectangle([(bar_x, bar_y), (bar_x + bar_width, bar_y + bar_height)], fill='white')
tinted_draw.rectangle([
    (left_weight_x, left_weight_y),
    (left_weight_x + weight_width, left_weight_y + weight_height)
], fill='white')
tinted_draw.rectangle([
    (right_weight_x, left_weight_y),
    (right_weight_x + weight_width, left_weight_y + weight_height)
], fill='white')
tinted.save('/tmp/AppIcon-tinted.png')

print("图标创建成功！")
print("- /tmp/AppIcon-1024.png")
print("- /tmp/AppIcon-tinted.png")
PYTHON_SCRIPT

# 运行Python脚本
if command -v python3 &> /dev/null; then
    python3 /tmp/create_icon.py

    # 复制到正确位置
    cp /tmp/AppIcon-1024.png "$ICON_PATH/AppIcon-1024.png"
    cp /tmp/AppIcon-tinted.png "$ICON_PATH/AppIcon-tinted.png"

    echo "✅ 图标已安装到: $ICON_PATH"
else
    echo "⚠️ 需要安装 Python 3 和 PIL (pip3 install Pillow)"
    echo "或者手动创建图标："
    echo "1. 打开 Figma/Sketch"
    echo "2. 创建 1024x1024 画板，黑色背景"
    echo "3. 绘制白色哑铃图标"
    echo "4. 导出为 AppIcon-1024.png 和 AppIcon-tinted.png"
    echo "5. 放到: $ICON_PATH/"
fi
