--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:彩度
---min=0
---max=100
---step=0.1
local track_saturation = 70

---$track:明度
---min=0
---max=100
---step=0.1
local track_brightness = 70

---$track:しきい値
---min=0
---max=100
---step=0.1
local track_threshold = 10

--group:エッジ

---$track:色付ｴｯｼﾞ
---min=0
---max=100
---step=0.1
local track_colored_edge_opacity = 50

---$trac:しきい値ぼかし
---min=0
---max=100
---step=0.1
local track_threshold_blur = 8

---$track:縁補正
---min=0
---max=500
---step=1
local track_edge_correction = 1

---$track:エッジ強さ
---min=0
---max=1000
---step=0.1
local track_edge_strength = 100

---$track:エッジしきい値
---min=-100
---max=100
---step=0.01
local track_edge_threshold = 0

---$track:エッジぼかし
---min=0
---max=100
---step=1
local track_edge_blur = 1

-- require("T_Color_Module")
--[[pixelshader@pastel
---$include "./shaders/pastel.hlsl"
]]

local colored_edge_opacity = track_colored_edge_opacity / 100
if colored_edge_opacity > 0 then
    obj.setoption("drawtarget", "tempbuffer", obj.w, obj.h)
    obj.copybuffer("cache:org", "object")
    obj.copybuffer("tempbuffer", "object")
    obj.setoption("drawtarget", "tempbuffer")
    obj.effect(
        "エッジ抽出",
        "強さ",
        track_edge_strength,
        "しきい値",
        track_edge_threshold,
        "輝度エッジを抽出",
        1,
        "透明度エッジを抽出",
        0
    )
    obj.effect("縁取り", "サイズ", track_edge_correction, "ぼかし", track_edge_blur, "color", 0xffffff)
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.setoption("blend", "none")
    obj.copybuffer("cache:Edg", "tempbuffer")
    obj.copybuffer("object", "cache:org")
end
obj.pixelshader("pastel", "object", "object", {
    track_saturation / 100,
    track_brightness / 100,
    track_threshold / 100,
    track_threshold_blur or 0,
})
obj.setoption("draw_state", false)
if colored_edge_opacity > 0 then
    obj.copybuffer("tempbuffer", "object")
    obj.copybuffer("object", "cache:Edg")
    obj.draw(0, 0, 0, 1, colored_edge_opacity)
    obj.copybuffer("object", "tempbuffer")
end
