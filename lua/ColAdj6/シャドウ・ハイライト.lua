--label:tim2\T_Color_Module.anm
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

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.save_g_image(userdata, w, h)
obj.effect("ぼかし", "範囲", track_range, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.shadow_highlight(userdata, w, h, -track_black_crush_adjust / 100, track_white_clip_adjust / 100)
obj.putpixeldata("object", userdata, w, h, "bgra")