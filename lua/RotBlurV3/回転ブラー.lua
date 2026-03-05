--label:tim2\T_RotBlur_Module.anm\回転ブラー
--track0:中心X,-5000,5000,0
--track1:中心Y,-5000,5000,0
--track2:ブラー量,0,1000,30
--track3:基準位置,-100,100,0
--value@ck:サイズ保持/chk,1
--value@sdw:角度解像度ダウン,0
--value@ap:高精度表示/chk,1
--value@sp:高精度出力/chk,1

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
local dx = obj.track0
local dy = obj.track1

local BL = (not obj.getinfo("saving") and ap == 1) or (obj.getinfo("saving") and sp == 1)
local TRB = BL and T_RotBlur_Module.RotBlur_S or T_RotBlur_Module.RotBlur_L
TRB(userdata, w, h, obj.track2, dx, dy, obj.track3, sdw)
obj.putpixeldata(userdata)
