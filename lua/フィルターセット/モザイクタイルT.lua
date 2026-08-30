--label:${ROOT_CATEGORY}\加工\@T_Filter_Module
--filter
---$track:サイズ
---min=0
---max=2000
---step=0.1
local track_tile_size = 50

---$track:溝幅
---min=0
---max=1000
---step=0.1
local track_groove_width = 1

---$track:細かさ
---min=1
---max=100
---step=0.1
local track_noise_detail = 10

---$track:変形量
---min=-500
---max=500
---step=0.1
local track_deformation_amount = 30

---$track:縦横比%
---min=1
---max=400
---step=0.1
local track_aspect_ratio_percent = 100

---$track:溝明度
---min=-255
---max=255
---step=1
local track_groove_brightness = 70

---$track:凸エッジ幅
---min=0
---max=50
---step=0.1
local track_edge_width = 2

---$track:凸エッジ高さ
---min=-20
---max=20
---step=0.1
local track_edge_height = 1

---$select:凸エッジ角度
---左=-180
---左上=-135
---上=-90
---右上=-45
---右=0
---右下=45
---下=90
---左下=135
local select_edge_angle = -45

---$track:がさつき
---min=0
---max=200
---step=0.1
local track_roughness = 50

---$track:変化速度
---min=-100
---max=100
---step=0.1
local track_change_speed = 0

---$track:乱数シード
---min=0
---max=9999
---step=1
local track_seed = 0

---$check:がさつきを有効化
local check_enable_roughness = true

--hide@track_roughness:check_enable_roughness==0

local w, h = obj.getpixel()
track_aspect_ratio_percent = track_aspect_ratio_percent * 0.01
local tile_width = track_tile_size
local tile_height = tile_width * track_aspect_ratio_percent
local groove_width = track_groove_width
local noise_period = track_noise_detail * 0.1
local deformation_amount = track_deformation_amount
local half_canvas_width, half_canvas_height = w + tile_width, h + tile_height

--[[pixelshader@sharp
---$include "./shaders/sharp.hlsl"
]]
--[[pixelshader@emboss
---$include "./shaders/emboss.hlsl"
]]
--[[pixelshader@flat_rgb
---$include "./shaders/flat_rgb.hlsl"
]]

if check_enable_roughness then
    local edge_direction_index = math.floor((select_edge_angle + 45) / 45 - 0.5)
    edge_direction_index = edge_direction_index % 8
    obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
    obj.pixelshader("sharp", "object", "object", { 0.5 })
    obj.pixelshader("emboss", "object", "object", { track_roughness * 0.01, edge_direction_index })
    obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
end

obj.copybuffer("cache:ori", "object")
obj.effect("色調補正", "明るさ", track_groove_brightness)
obj.copybuffer("cache:D-ori", "object")
obj.setoption("drawtarget", "tempbuffer", half_canvas_width, half_canvas_height)
obj.load("figure", "四角形", 0xffffff, math.max(tile_width, tile_height))
half_canvas_width, half_canvas_height = half_canvas_width * 0.5, half_canvas_height * 0.5
local horizontal_tile_count = math.ceil(half_canvas_width / tile_width)
local vertical_tile_count = math.ceil(half_canvas_height / tile_height)
local groove_start = -math.floor(groove_width * 0.5)
local groove_end = groove_start + groove_width
for i = -horizontal_tile_count, horizontal_tile_count do
    local x = i * tile_width
    obj.drawpoly(
        x + groove_start,
        -half_canvas_height,
        0,
        x + groove_end,
        -half_canvas_height,
        0,
        x + groove_end,
        half_canvas_height,
        0,
        x + groove_start,
        half_canvas_height,
        0
    )
end
for j = -vertical_tile_count, vertical_tile_count do
    local y = j * tile_height
    obj.drawpoly(
        -half_canvas_width,
        y + groove_start,
        0,
        half_canvas_width,
        y + groove_start,
        0,
        half_canvas_width,
        y + groove_end,
        0,
        -half_canvas_width,
        y + groove_end,
        0
    )
end
obj.copybuffer("cache:Lat", "tempbuffer")

obj.load("figure", "四角形", 0xffffff, 2 * math.max(half_canvas_width, half_canvas_height))
obj.effect(
    "ノイズ",
    "mode",
    1,
    "周期X",
    noise_period,
    "周期Y",
    noise_period,
    "seed",
    track_seed,
    "変化速度",
    track_change_speed
)
obj.pixelshader("flat_rgb", "object", "object", { 1 })
obj.setoption("blend", "none")
obj.draw()
obj.load("figure", "四角形", 0xffffff, 2 * math.max(half_canvas_width, half_canvas_height))
obj.effect(
    "ノイズ",
    "mode",
    1,
    "周期X",
    noise_period,
    "周期Y",
    noise_period,
    "seed",
    track_seed + 100,
    "変化速度",
    track_change_speed
)
obj.pixelshader("flat_rgb", "object", "object", { 2 })
obj.setoption("blend", "overlay")
obj.draw()
obj.setoption("blend", "none")
obj.copybuffer("object", "cache:Lat")
obj.effect(
    "ディスプレイスメントマップ",
    "変形方法",
    "移動変形",
    "マップの種類",
    "*tempbuffer",
    "元のサイズに合わせる",
    1,
    "変形X",
    deformation_amount,
    "変形Y",
    deformation_amount
)

obj.copybuffer("tempbuffer", "cache:ori")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.copybuffer("object", "tempbuffer")
obj.effect("凸エッジ", "幅", track_edge_width, "高さ", track_edge_height, "角度", select_edge_angle)
obj.copybuffer("tempbuffer", "cache:D-ori")
obj.setoption("blend", "none")
obj.draw()
obj.load("tempbuffer")
