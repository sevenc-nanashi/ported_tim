--label:tim2\T_Color_Module.anm\トライトーン
---$track:飽和点1
---min=0
---max=255
---step=1
local rename_me_track0 = 0

---$track:中心点
---min=0
---max=255
---step=1
local rename_me_track1 = 128

---$track:飽和点2
---min=0
---max=255
---step=1
local rename_me_track2 = 255

---$value:ミッドトーン色無視/chk
local egm = 0

---$value:シャドウ/col
local col3 = 0x000000

---$value: ミッドトーン/col
local col2 = 0xb5982c

---$value: ハイライト/col
local col1 = 0xffffff

---$check:新バージョン
local rename_me_check0 = true

local p1, p2, p3
if rename_me_check0 then
    p3 = math.floor(rename_me_track0)
    p2 = math.floor(rename_me_track1)
    p1 = math.floor(rename_me_track2)
    p1, p3 = math.max(p1, p3), math.min(p1, p3)
else
    p1, p2, p3 = 255, 128, 0
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.TritoneV3(userdata, w, h, col1, col2, col3, p1, p2, p3, egm or 0)
obj.putpixeldata(userdata)
