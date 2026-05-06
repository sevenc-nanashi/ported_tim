--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:黒潰補正
---min=-1000
---max=1000
---step=0.1
local track_black_crush_adjust = 100

---$track:白飛補正
---min=-1000
---max=1000
---step=0.1
local track_white_clip_adjust = 100

---$track:範囲
---min=1
---max=100
---step=1
local track_range = 10

--[[pixelshader@shadow_highlight
---$include "./shaders/shadow_highlight.hlsl"
]]

obj.copybuffer("cache:shadow_highlight_original", "object")
obj.effect("ぼかし", "範囲", track_range, "サイズ固定", 1)
obj.pixelshader("shadow_highlight", "object", { "cache:shadow_highlight_original", "object" }, {
    -track_black_crush_adjust / 100,
    track_white_clip_adjust / 100,
})
