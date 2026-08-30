--label:${ROOT_CATEGORY}\抽出
---$track:半径
---min=1
---max=500
---step=1
local track_radius = 1

---$track:強度
---min=0
---max=1000
---step=0.1
local track_intensity = 300

---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 0

---$color:ライン色
local line_color = 0xff0000

---$color:背景色
local background_color = 0xffffff

---$track:背景透明度
---min=0
---max=100
---step=1
local track_background_opacity = 0

---$track:オリジナル透明度
---min=0
---max=100
---step=1
local track_original_opacity = 100

---$check:輝度反転
local check_invert_luminance = false

---$check:ラインのみ
local check_line_only = false

---$track:粒子化幅
---min=0
---max=1000
---step=1
local track_particle_width = 0

---$check:粒子[移動/参照]
local check_reference_particles = false

---$track:飛散方向(開始)
---min=0
---max=360
---step=1
local track_scatter_direction_start = 0

---$track:飛散方向(終了)
---min=0
---max=360
---step=1
local track_scatter_direction_end = 360

---$check:飛散ループ
local check_loop_scatter = true

---$track:シード
---min=0
---max=1000000
---step=1
local track_seed = 0

---$track:シード変化間隔
---min=0
---max=600
---step=1
local track_seed_change_interval = 0

---$track:追加領域サイズ
---min=0
---max=500
---step=1
local track_expansion_size = 0

--hide@background_color:check_line_only==1
--hide@track_background_opacity:check_line_only==1
--hide@track_original_opacity:check_line_only==1

if track_seed_change_interval > 0 then
    track_seed = track_seed + math.floor(obj.time * obj.framerate / track_seed_change_interval)
end
local line_module = obj.module("tim2")
if check_invert_luminance then
    obj.effect("反転", "輝度反転", 1)
end
if track_expansion_size > 0 then
    track_expansion_size = (track_expansion_size + 1) / 2
    obj.effect(
        "領域拡張",
        "上",
        track_expansion_size,
        "下",
        track_expansion_size,
        "右",
        track_expansion_size,
        "左",
        track_expansion_size
    )
end
local pixel_data, width, height = obj.getpixeldata("object", "bgra")
line_module.lineextra_set_public_image(pixel_data, width, height)
obj.effect("ぼかし", "範囲", track_radius, "サイズ固定", 1)
pixel_data, width, height = obj.getpixeldata("object", "bgra")
line_module.lineextra_line_ext(
    pixel_data,
    width,
    height,
    track_intensity,
    track_particle_width,
    track_threshold,
    check_line_only,
    track_background_opacity,
    track_original_opacity,
    line_color,
    background_color,
    check_reference_particles,
    check_loop_scatter,
    track_scatter_direction_start,
    track_scatter_direction_end,
    track_seed
)
obj.putpixeldata("object", pixel_data, width, height, "bgra")
