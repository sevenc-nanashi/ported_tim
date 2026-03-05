--label:tim2\T_RotBlur_Module.anm\回転ブラー
---$track:中心X
---min=-5000
---max=5000
---step=0.1
local rename_me_track0 = 0

---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local rename_me_track1 = 0

---$track:ブラー量
---min=0
---max=1000
---step=0.1
local rename_me_track2 = 30

---$track:基準位置
---min=-100
---max=100
---step=0.1
local rename_me_track3 = 0

---$value:サイズ保持/chk
local ck = 1

---$value:角度解像度ダウン
local sdw = 0

---$value:高精度表示/chk
local ap = 1

---$value:高精度出力/chk
local sp = 1

local userdata, w, h
w, h = obj.getpixel()
local r = math.sqrt(w * w + h * h)
if ck == 0 then
    local addX, addY = math.ceil((r - w) / 2 + 1), math.ceil((r - h) / 2 + 1)
    obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
end
require("T_RotBlur_Module")
userdata, w, h = obj.getpixeldata()
obj.setanchor("track", 0, "line")
local dx = rename_me_track0
local dy = rename_me_track1

local BL = (not obj.getinfo("saving") and ap == 1) or (obj.getinfo("saving") and sp == 1)
local TRB = BL and T_RotBlur_Module.RotBlur_S or T_RotBlur_Module.RotBlur_L
TRB(userdata, w, h, rename_me_track2, dx, dy, rename_me_track3, sdw)
obj.putpixeldata(userdata)
