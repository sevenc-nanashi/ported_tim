--label:tim2\色調整\@T_Color_Module
--filter
---$track:飽和点1
---min=0
---max=255
---step=1
local track_n_1 = 0

---$track:中心点
---min=0
---max=255
---step=1
local track_center = 153

---$track:飽和点2
---min=0
---max=255
---step=1
local track_n_2 = 230

-- local p3 = math.floor(track_n_1)
-- local p2 = math.floor(track_center)
-- local p1 = math.floor(track_n_2)
-- p1, p3 = math.max(p1, p3), math.min(p1, p3)
-- require("T_Color_Module")
-- local T_Color_Module = obj.module("tim2")
-- local userdata, w, h = obj.getpixeldata("object", "bgra")
-- T_Color_Module.color_tritone_v3(userdata, w, h, 0xffffff, 0xfd9501, 0x0c0500, p1, p2, p3, 0)
-- obj.putpixeldata("object", userdata, w, h, "bgra")
obj.effect("トライトーン@T_Color_Module@tim.anm2", "飽和点1", track_n_1, "中心点", track_center, "飽和点2", track_n_2, "シャドウ", 0x0c0500, "ミッドトーン", 0xfd9501, "ハイライト", 0xffffff)
