--label:tim2\装飾
---$track:サイズ
---min=0
---max=500
---step=0.1
local track_size = 50

---$track:境界ぼかし
---min=0.1
---max=500
---step=0.1
local track_boundary_blur = 2

---$track:α基準
---min=0
---max=254
---step=1
local alpha_base = 128

---$track:合成量
---min=-100
---max=100
---step=0.1
local track_blend_amount = 100

-- TODO: 需要があれば実装
-- ---$check:高精度
-- local high_precision = false

---$color:色1
local color1 = 0xffffff

---$color:色2
local color2 = 0x0

---$check:距離グラデ
local gradient = true

--group:錯覚補正,false
---$check:錯覚補正を有効化
local enable_adjust = false

---$track:色ぼかし量%
---min=0
---max=200
---step=0.1
local adjust_color_blur = 25

---$track:αぼかし量%
---min=0
---max=200
---step=0.1
local adjust_alpha_blur = 25
--group:

---$select:モード
---外側=0
---両方=1
---内側=2
local mode = 0

--[[pixelshader@distance_map:
---$include "./shaders/distance_map.hlsl"
]]
--[[pixelshader@map_color_with_alpha:
#define ENTRY_NAME map_color_with_alpha
#define WITH_ALPHA 1
---$include "./shaders/map_color.hlsl"
]]
--[[pixelshader@map_color_without_alpha:
#define ENTRY_NAME map_color_without_alpha
---$include "./shaders/map_color.hlsl"
]]
--[[pixelshader@set_alpha:
---$include "./shaders/set_alpha.hlsl"
]]

local outline_size = track_size
local boundary_blur = track_boundary_blur
local blend_amount = track_blend_amount / 100
local outline_color = color1 or 0xffffff
local fill_color = color2 or 0x0
local expanded_size = -math.floor(-outline_size)
adjust_color_blur = outline_size * (adjust_color_blur or 0) / 100
adjust_alpha_blur = boundary_blur * (adjust_alpha_blur or 0) / 100
mode = mode or 0

obj.copybuffer("cache:Org", "obj")
if mode == 0 then
    obj.effect("領域拡張", "上", expanded_size, "下", expanded_size, "右", expanded_size, "左", expanded_size)
elseif mode == 1 then
    obj.effect("領域拡張", "上", expanded_size, "下", expanded_size, "右", expanded_size, "左", expanded_size)
    obj.effect("エッジ抽出", "透明度エッジを抽出", 1, "輝度エッジを抽出", 0)
else
    obj.effect("反転", "透明度反転", 1)
end

-- local pixel_data, width, height = obj.getpixeldata("object", "bgra")
local width, height = obj.getpixel()
local color1_r, color1_g, color1_b = RGB(outline_color)
local color2_r, color2_g, color2_b = RGB(fill_color)
if not gradient then
    color2_r, color2_g, color2_b = color1_r, color1_g, color1_b
end

obj.clearbuffer("cache:distance_map", width, height)
local use_gpu = outline_size < 50
if use_gpu then
    obj.pixelshader("distance_map", "cache:distance_map", "object", {
        width,
        height,
        alpha_base / 255,
        boundary_blur,
        outline_size,
    })
else
    local tim2 = obj.module("tim2")
    local original_pixel_data, w, h = obj.getpixeldata("object", "rgba")
    local dest_pixel_data = obj.getpixeldata("cache:distance_map", "rgba")
    tim2.framing_create_distance_map(
        original_pixel_data,
        dest_pixel_data,
        w, h,
        alpha_base,
        boundary_blur,
        outline_size)
    obj.putpixeldata("cache:distance_map", dest_pixel_data, w, h, "rgba")
end

obj.clearbuffer("cache:color_only", width, height)
obj.pixelshader("map_color_without_alpha", "cache:color_only", "cache:distance_map", {
    color1_r / 255,
    color1_g / 255,
    color1_b / 255,
    color2_r / 255,
    color2_g / 255,
    color2_b / 255,
})
obj.clearbuffer("cache:premult_alpha", width, height)
obj.pixelshader("map_color_with_alpha", "cache:premult_alpha", "cache:distance_map", {
    color1_r / 255,
    color1_g / 255,
    color1_b / 255,
    color2_r / 255,
    color2_g / 255,
    color2_b / 255,
})
-- if high_precision then
--     tim2.framing_framing_hi(pixel_data, width, height, outline_size, boundary_blur, alpha_base, outline_color, fill_color, gradient)
-- else
--     tim2.framing_framing(pixel_data, width, height, outline_size, boundary_blur, alpha_base, outline_color, fill_color, gradient)
-- end
-- obj.putpixeldata("object", pixel_data, width, height, "bgra")

if enable_adjust then
    if adjust_color_blur > 0 then
        -- local pixel_data, width, height = obj.getpixeldata("object", "bgra")
        -- tim2.framing_re_alpha(pixel_data, width, height)
        -- obj.putpixeldata("object", pixel_data, width, height, "bgra")
        obj.copybuffer("object", "cache:color_only")
        obj.effect("ぼかし", "範囲", adjust_color_blur, "サイズ固定", 1)
        obj.copybuffer("cache:color_only", "object")
        obj.pixelshader("set_alpha",
            "object", {
                "object",
                "cache:premult_alpha",
            })
        -- pixel_data, width, height = obj.getpixeldata("object", "bgra")
        -- tim2.framing_set_alpha(pixel_data, width, height)
        -- obj.putpixeldata("object", pixel_data, width, height, "bgra")
    else
        obj.copybuffer("object", "cache:premult_alpha")
    end
    if adjust_alpha_blur > 0 then
        obj.effect("ぼかし", "範囲", adjust_alpha_blur, "サイズ固定", 1)
        obj.pixelshader("set_alpha",
            "object", {
                "cache:color_only",
                "object",
            })
    end
else
    obj.copybuffer("object", "cache:premult_alpha")
end

obj.setoption("drawtarget", "tempbuffer", width, height)
if mode == 0 then
    if blend_amount ~= 0 then
        obj.copybuffer("tempbuffer", "object")
        obj.copybuffer("object", "cache:Org")
        if blend_amount < 0 then
            obj.setoption("blend", "alpha_sub")
            blend_amount = -blend_amount
        end
        obj.draw(0, 0, 0, 1, blend_amount)
        obj.copybuffer("object", "tempbuffer")
    end
elseif mode == 1 then
    if blend_amount > 0 then
        obj.copybuffer("cache:Frm", "obj")
        obj.copybuffer("obj", "cache:Org")
        obj.draw(0, 0, 0, 1, blend_amount)
        obj.copybuffer("obj", "cache:Frm")
        obj.draw()
        obj.copybuffer("obj", "tmp")
    end
else
    if blend_amount < 1 then
        obj.copybuffer("cache:Frm", "obj")
        obj.copybuffer("obj", "cache:Org")
        obj.draw(0, 0, 0, 1, blend_amount)
        obj.copybuffer("obj", "cache:Frm")
    else
        obj.copybuffer("tmp", "cache:Org")
    end
    obj.draw()
    obj.copybuffer("obj", "cache:Org")
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.copybuffer("obj", "tmp")
end
obj.setoption("blend", 0)
