--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$select:モード
---最大=1
---最小=2
local select_operation = 1

---$select:チャンネル
---全て=1
---R=2
---G=3
---B=4
local select_channel = 1

---$track:範囲
---min=1
---max=1000
---step=1
local track_range = 10

---$track:角度
---min=-3600
---max=3600
---step=0.1
---zero_label=
---scale=0.05
local track_angle = 0

---$select:形状
---四角=0
---円=1
---菱形=2
---十字=3
---六角形=4
local select_shape = 0

---$check:水平
local check_horizontal = true

---$check:垂直
local check_vertical = true

---$track:縦横比
---min=1
---max=100
---step=0.01
local track_aspect_ratio = 100

---$check:範囲対称
local check_symmetric_range = true

---$check:色も保存
local check_preserve_color = false

---$track:限界範囲
---min=1
---max=1000
---step=1
local track_range_limit = 50

---$track:α拡張
---min=0
---max=255
---step=1
local track_alpha_expansion = 0

---$check:結果を保存(同条件1度のみ)
local check_cache_result = false

--hide@check_horizontal:select_shape~=0
--hide@check_vertical:select_shape~=0
--hide@check_symmetric_range:select_shape~=0
--hide@track_range_limit:select_shape==0
--hide@track_range_limit:select_shape==3

-- require("T_Color_Module")
local color_module = obj.module("tim2")
local rotation_angle = -track_angle % 360
local aspect_ratio = (track_aspect_ratio or 100) / 100
local shape = math.floor(select_shape or 0)
local range_limit = (track_range_limit or 50)
local effect_range = track_range
local alpha_expansion = track_alpha_expansion or 0
if shape > 0 then
    if shape ~= 3 then
        effect_range = math.min(effect_range, range_limit)
    end
end
effect_range = math.max(1, effect_range)
local cache_status = 0
if check_cache_result then
    local pixel_data, width, height = obj.getpixeldata("object", "bgra")
    cache_status = color_module.color_minimax_check(
        pixel_data,
        width,
        height,
        math.floor(select_operation),
        math.floor(select_channel),
        effect_range,
        rotation_angle,
        check_horizontal,
        check_vertical,
        aspect_ratio,
        check_symmetric_range,
        check_preserve_color,
        shape
    )
    if cache_status == 1 then
        obj.putpixeldata("object", pixel_data, width, height, "bgra")
    end
end
if cache_status == 0 then
    local original_width, original_height = obj.getpixel()
    if rotation_angle ~= 0 then
        local rotation_radians = rotation_angle / 180 * math.pi
        local rotated_width = original_width * math.abs(math.cos(rotation_radians))
            + original_height * math.abs(math.sin(rotation_radians))
        local rotated_height = original_height * math.abs(math.cos(rotation_radians))
            + original_width * math.abs(math.sin(rotation_radians))
        local expanded_width = rotated_width + (rotated_width - original_width) % 2
        local expanded_height = rotated_height + (rotated_height - original_height) % 2
        local rotated_quarter_turn = 0
        local working_width, working_height = original_width, original_height
        if rotated_width < original_width then
            obj.effect("ローテーション", "90度回転", 1)
            rotated_quarter_turn = 1
            working_width, working_height = working_height, working_width
        end
        obj.effect("領域拡張", "右", expanded_width - working_width, "下", expanded_height - working_height)
        local pixel_data, width, height = obj.getpixeldata("object", "bgra")
        color_module.color_minimax_rot(
            pixel_data,
            width,
            height,
            working_width,
            working_height,
            rotation_radians,
            rotated_quarter_turn,
            select_operation
        )
        obj.putpixeldata("object", pixel_data, width, height, "bgra")
    end
    local pixel_data, width, height = obj.getpixeldata("object", "bgra")
    color_module.color_minimax(
        pixel_data,
        width,
        height,
        select_operation,
        effect_range,
        select_channel,
        check_horizontal,
        check_vertical,
        check_symmetric_range,
        aspect_ratio,
        check_preserve_color,
        shape,
        alpha_expansion
    )
    obj.putpixeldata("object", pixel_data, width, height, "bgra")
    if rotation_angle ~= 0 then
        obj.setoption("drawtarget", "tempbuffer", original_width, original_height)
        obj.draw(0, 0, 0, 1, 1, 0, 0, -rotation_angle)
        obj.copybuffer("object", "tempbuffer")
    end
    if check_cache_result then
        local pixel_data, width, height = obj.getpixeldata("object", "bgra")
        color_module.color_minimax_save(pixel_data, width, height)
    end
end
obj.cx = 0
obj.cy = 0
