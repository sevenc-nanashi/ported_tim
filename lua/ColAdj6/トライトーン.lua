--label:tim2\色調整\T_Color_Module.anm
---$track:飽和点1
---min=0
---max=255
---step=1
local track_n_1 = 0

---$track:中心点
---min=0
---max=255
---step=1
local track_center = 128

---$track:飽和点2
---min=0
---max=255
---step=1
local track_n_2 = 255

---$check:ミッドトーン色無視
local egm = 0

---$color:シャドウ
local col3 = 0x000000

---$color: ミッドトーン
local col2 = 0xb5982c

---$color: ハイライト
local col1 = 0xffffff

---$check:新バージョン
local check0 = true

local p1, p2, p3
if check0 then
    p3 = math.floor(track_n_1)
    p2 = math.floor(track_center)
    p1 = math.floor(track_n_2)
    p1, p3 = math.max(p1, p3), math.min(p1, p3)
else
    p1, p2, p3 = 255, 128, 0
end
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_tritone_v3(userdata, w, h, col1, col2, col3, p1, p2, p3, egm or 0)
obj.putpixeldata("object", userdata, w, h, "bgra")