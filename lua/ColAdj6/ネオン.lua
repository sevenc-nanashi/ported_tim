--label:tim2\未分類\T_Color_Module.anm
---$track:輝度中心
---min=-200
---max=200
---step=0.1
local track_luminance_center = 0

---$track:輝度範囲
---min=1
---max=500
---step=0.1
local track_luminance_range = 10

---$track:強度
---min=0
---max=500
---step=0.1
local track_intensity = 100

---$track:ぼかし
---min=0
---max=500
---step=0.1
local track_blur = 5

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local C = track_luminance_center / 100 + 0.5
local B = track_luminance_range * 0.01
local S = track_intensity * 0.01
local ar = -S / (B * B)
local br = ar * (-2 * C)
local cr = ar * (C * C - B * B)
obj.effect("ぼかし", "範囲", track_blur, "サイズ固定", 1)
T_Color_Module.set_tone_curve(0, 0, 0, ar, br, cr, 0, 0, 0)
T_Color_Module.set_tone_curve(1, 0, 0, ar, br, cr, 0, 0, 0)
T_Color_Module.set_tone_curve(2, 0, 0, ar, br, cr, 0, 0, 0)
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.sim_tone_curve(userdata, w, h, false)
obj.putpixeldata("object", userdata, w, h, "bgra")