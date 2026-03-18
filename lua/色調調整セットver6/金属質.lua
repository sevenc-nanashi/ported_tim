--label:tim2\色調整\@T_Color_Module
--filter
---$track:飽和点1
---min=0
---max=255
---step=1
local track_n_1 = 64

---$track:飽和点2
---min=0
---max=255
---step=1
local track_n_2 = 178

-- local p3 = math.floor(track_n_1)
-- local p1 = math.floor(track_n_2)
-- p1, p3 = math.max(p1, p3), math.min(p1, p3)
-- -- require("T_Color_Module")
-- local T_Color_Module = obj.module("tim2")
-- local userdata, w, h = obj.getpixeldata("object", "bgra")
-- T_Color_Module.color_tritone_v3(userdata, w, h, 0xffffff, 0xffffff, 0x2e1601, p1, p1, p3, 0)
-- obj.putpixeldata("object", userdata, w, h, "bgra")
obj.effect("トライトーン@T_Color_Module@tim.anm2", "飽和点1", track_n_1, "中心点", track_n_1, "飽和点2", track_n_2, "シャドウ", 0x2e1601, "ミッドトーン", 0xffffff, "ハイライト", 0xffffff)
