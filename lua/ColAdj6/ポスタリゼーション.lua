--label:tim2\色調整\T_Color_Module.anm
--filter
---$track:R階調数
---min=2
---max=256
---step=1
local track_r_count = 8

---$track:G階調数
---min=2
---max=256
---step=1
local track_g_count = 8

---$track:B階調数
---min=2
---max=256
---step=1
local track_b_count = 8

---$track:サイズ
---min=1
---max=1000
---step=0.1
local track_size = 1

---$check:全体をRで調整
local check0 = false

---$check:誤差拡散
local ED = false

local sz = math.max(1, track_size) --追加のため
local w0, h0
-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local r, g, b
if check0 then
    r = track_r_count
    g, b = r, r
else
    r, g, b = track_r_count, track_g_count, track_b_count
end
if sz > 1 then
    w0, h0 = obj.getpixel()
    obj.effect("リサイズ", "拡大率", 100 / sz)
end
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_posterize(userdata, w, h, r, g, b, ED)
obj.putpixeldata("object", userdata, w, h, "bgra")
if sz > 1 then
    obj.effect("リサイズ", "X", w0, "Y", h0, "補間なし", 1, "ドット数でサイズ指定", 1)
end
