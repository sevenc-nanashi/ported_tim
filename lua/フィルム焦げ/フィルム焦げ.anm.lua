--label:${ROOT_CATEGORY}\加工
---$track:焼け
---min=0
---max=200
---step=0.1
local track_burn = 30

---$track:輪郭ぼかし
---min=0
---max=100
---step=0.1
local track_contour_blur = 35

---$track:燃焼半径
---min=0
---max=5000
---step=0.1
local track_radius = 50

---$track:乱数
---min=0
---max=10000
---step=0.1
local track_random_seed = 0

---$track:発火点集中
---min=0
---max=1000
---step=0.1
local track_ignition_concentration = 50

---$color:燃焼色
local burn_color = 0x000000

---$track:燃焼ぼかし(%)
---min=0
---max=100
---step=0.1
local track_burn_blur_percent = 5

---$track:位置ズレ(%)
---min=0
---max=100
---step=0.1
local track_position_offset_percent = 5

---$track:縁発光
---min=0
---max=1000
---step=1
local track_edge_glow = 300

---$track:縁発光拡散(%)
---min=0
---max=100
---step=0.1
local track_edge_glow_diffusion_percent = 7.5

---$check:縁発光
local check_edge_glow = false

--hide@track_edge_glow:check_edge_glow==0
--hide@track_edge_glow_diffusion_percent:check_edge_glow==0

local burn_amount = track_burn * 0.01
local contour_blur_ratio = track_contour_blur * 0.01
local radius_ratio = track_radius * 0.01
local random_seed = track_random_seed
track_ignition_concentration = track_ignition_concentration * 0.001
track_position_offset_percent = track_position_offset_percent * 0.01
track_burn_blur_percent = track_burn_blur_percent * 0.01
track_edge_glow_diffusion_percent = track_edge_glow_diffusion_percent * 0.01

-- NOTE: AviUtl2では、alpha_subを複数回かけるとバグるため、マスクのバッファを作ってそこに描画してから合成する

obj.copybuffer("cache:original", "object")

local image_width, image_height = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", image_width, image_height)

local canvas_scale = math.max(image_width, image_height)
local burn_radius = radius_ratio * canvas_scale
local position_jitter = canvas_scale * track_position_offset_percent

obj.load("figure", "円", 0xffffff, 100)
obj.effect("ぼかし", "範囲", 100 * contour_blur_ratio)

for i = -5, 5 do
    for j = -5, 5 do
        local ignition_size = (
            burn_amount
            + obj.rand(-500, 0, i, j + random_seed) * 0.001
            + 0.5 * math.exp(-track_ignition_concentration * (i * i + j * j))
            - 0.5
        ) * burn_radius
        if ignition_size < 0 then
            ignition_size = 0
        end
        local jitter_x = obj.rand(-position_jitter, position_jitter, i, j + 1000 + random_seed)
        local jitter_y = obj.rand(-position_jitter, position_jitter, i, j + 2000 + random_seed)
        obj.draw(i * canvas_scale * 0.1 + jitter_x, j * canvas_scale * 0.1 + jitter_y, 0, ignition_size * 0.01)
    end
end

obj.copybuffer("cache:mask", "tempbuffer")
obj.copybuffer("tempbuffer", "cache:original")
obj.copybuffer("object", "cache:mask")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", "none")
obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
obj.effect("縁取り", "サイズ", 1, "ぼかし", track_burn_blur_percent * canvas_scale, "color", burn_color)
obj.draw()
obj.load("tempbuffer")

if check_edge_glow then
    -- AviUtl2では逆光で縁が光ってしまうため、領域拡張+クリッピングで光る部分を外に出す
    local glow_margin = canvas_scale * track_edge_glow_diffusion_percent
    obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
    obj.effect(
        "領域拡張",
        "塗りつぶし",
        1,
        "上",
        glow_margin,
        "下",
        glow_margin,
        "左",
        glow_margin,
        "右",
        glow_margin
    )
    obj.effect(
        "ライト",
        "強さ",
        track_edge_glow,
        "拡散",
        canvas_scale * track_edge_glow_diffusion_percent,
        "逆光",
        1
    )
    obj.effect("クリッピング", "上", glow_margin, "下", glow_margin, "左", glow_margin, "右", glow_margin)
    obj.draw()
    obj.load("tempbuffer")
end
