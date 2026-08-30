--label:${ROOT_CATEGORY}\加工
---$track:強度
---min=-200
---max=200
---step=0.1
local track_intensity = 50

---$track:サイズ
---min=3
---max=500
---step=1
local track_cell_size = 10

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 0

---$track:ぼかし%
---min=0
---max=500
---step=0.1
local track_blur_percent = 100

---$color:色1
local color_primary = 0xffffff

---$color:色2
local color_secondary = nil

---$check:直線
local check_straight_lines = 0

---$check:網表示
local check_show_grid_only = 0

---$check:ブロック描画
local check_draw_blocks = false

--hide@track_blur_percent:check_draw_blocks==1

local intensity_ratio = track_intensity / 100
local cell_size = math.floor(track_cell_size)
local original_width, original_height = obj.getpixel()
local rotation_degrees = track_angle
local blur_ratio = track_blur_percent / 100
local gradient_type, gradient_width
if check_straight_lines == 0 then
    gradient_type, gradient_width = 1, 100
else
    gradient_type, gradient_width = 3, 69
end
if color_secondary == nil then
    local r, g, b = RGB(color_primary)
    color_secondary = RGB(255 - r, 255 - g, 255 - b)
end
if rotation_degrees ~= 0 then
    local absolute_sine = math.abs(math.sin(rotation_degrees * math.pi / 180))
    local absolute_cosine = math.abs(math.cos(rotation_degrees * math.pi / 180))
    local rotated_width = original_width * absolute_cosine + original_height * absolute_sine
    local rotated_height = original_width * absolute_sine + original_height * absolute_cosine
    obj.setoption("drawtarget", "tempbuffer", rotated_width + cell_size, rotated_height + cell_size)
    obj.effect(
        "領域拡張",
        "上",
        cell_size,
        "下",
        cell_size,
        "左",
        cell_size,
        "右",
        cell_size,
        "塗りつぶし",
        1
    )
    obj.draw(0, 0, 0, 1, 1, 0, 0, -rotation_degrees)
    obj.copybuffer("object", "tempbuffer")
end
local w, h = obj.getpixel()
local horizontal_repeat_count = 2 * math.ceil(0.5 * w / cell_size)
local vertical_repeat_count = 2 * math.ceil(0.5 * h / cell_size)
if check_draw_blocks then
    local canvas_width, canvas_height = horizontal_repeat_count * cell_size, vertical_repeat_count * cell_size
    local canvas_offset_x, canvas_offset_y = (canvas_width - w) / 2, (canvas_height - h) / 2
    obj.effect(
        "領域拡張",
        "上",
        canvas_offset_y,
        "下",
        canvas_offset_y,
        "左",
        canvas_offset_x,
        "右",
        canvas_offset_x,
        "塗りつぶし",
        1
    )
    obj.effect(
        "リサイズ",
        "X",
        horizontal_repeat_count,
        "Y",
        vertical_repeat_count,
        "ドット数でサイズ指定",
        1
    )
    obj.effect(
        "リサイズ",
        "X",
        canvas_width,
        "Y",
        canvas_height,
        "補間なし",
        1,
        "ドット数でサイズ指定",
        1
    )
    obj.effect(
        "クリッピング",
        "上",
        canvas_offset_y,
        "下",
        canvas_offset_y,
        "左",
        canvas_offset_x,
        "右",
        canvas_offset_x
    )
else
    obj.effect("ぼかし", "範囲", cell_size * blur_ratio, "サイズ固定", 1)
end
if intensity_ratio ~= 0 or check_show_grid_only == 1 then
    obj.copybuffer("cache:ORGL", "object")
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.load("figure", "四角形", color_secondary, 100)
    obj.effect(
        "グラデーション",
        "type",
        gradient_type,
        "強さ",
        75,
        "幅",
        gradient_width,
        "color",
        color_primary,
        "color2",
        color_secondary
    )
    if intensity_ratio < 0 then
        intensity_ratio = -intensity_ratio
        obj.effect("反転", "輝度反転", 1)
    end
    obj.effect("リサイズ", "X", cell_size, "Y", cell_size, "ドット数でサイズ指定", 1)

    if horizontal_repeat_count > 400 or vertical_repeat_count > 400 then
        local horizontal_block_count = math.floor(math.sqrt(horizontal_repeat_count))
        local vertical_block_count = math.floor(math.sqrt(vertical_repeat_count))
        horizontal_repeat_count = math.ceil(horizontal_repeat_count / horizontal_block_count)
        vertical_repeat_count = math.ceil(vertical_repeat_count / vertical_block_count)
        horizontal_block_count = horizontal_block_count + horizontal_block_count % 2
        vertical_block_count = vertical_block_count + vertical_block_count % 2
        obj.effect("画像ループ", "横回数", horizontal_block_count, "縦回数", vertical_block_count)
    end
    obj.effect("画像ループ", "横回数", horizontal_repeat_count, "縦回数", vertical_repeat_count)
    obj.draw()
    obj.copybuffer("object", "cache:ORGL")
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.copybuffer("object", "tempbuffer")

    if check_show_grid_only == 0 then
        obj.copybuffer("tempbuffer", "cache:ORGL")
        obj.setoption("blend", 5)
        if intensity_ratio <= 1 then
            obj.draw(0, 0, 0, 1, intensity_ratio)
        else
            obj.draw(0, 0, 0, 1, 1)
            obj.draw(0, 0, 0, 1, intensity_ratio - 1)
        end
    end
    obj.copybuffer("object", "tempbuffer")
    obj.setoption("blend", 0)
end
if rotation_degrees ~= 0 then
    obj.setoption("drawtarget", "tempbuffer", original_width, original_height)
    obj.draw(0, 0, 0, 1, 1, 0, 0, rotation_degrees)
    obj.copybuffer("object", "tempbuffer")
end
