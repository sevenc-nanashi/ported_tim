--label:tim2\T_Color_Module.anm\ポスタリゼーション
---$track:R階調数
---min=2
---max=256
---step=1
local rename_me_track0 = 8

---$track:G階調数
---min=2
---max=256
---step=1
local rename_me_track1 = 8

---$track:B階調数
---min=2
---max=256
---step=1
local rename_me_track2 = 8

---$track:サイズ
---min=1
---max=1000
---step=0.1
local rename_me_track3 = 1

---$check:全体をRで調整
local rename_me_check0 = false

---$value:誤差拡散/chk
local ED = 0

local ED2 = ED or 0 --追加のため
local sz = math.max(1, rename_me_track3) --追加のため
local w0, h0
require("T_Color_Module")
local r, g, b
if rename_me_check0 then
    r = rename_me_track0
    g, b = r, r
else
    r, g, b = rename_me_track0, rename_me_track1, rename_me_track2
end
if sz > 1 then
    w0, h0 = obj.getpixel()
    obj.effect("リサイズ", "拡大率", 100 / sz)
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Posterize(userdata, w, h, r, g, b, ED2)
obj.putpixeldata(userdata)
if sz > 1 then
    obj.effect("リサイズ", "X", w0, "Y", h0, "補間なし", 1, "ドット数でサイズ指定", 1)
end
