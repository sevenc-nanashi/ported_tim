--label:tim2\T_Color_Module.anm\ネオン
--track0:輝度中心,-200,200,0
--track1:輝度範囲,1,500,10
--track2:強度,0,500,100
--track3:ぼかし,0,500,5
require("T_Color_Module")
local C = obj.track0 / 100 + 0.5
local B = obj.track1 * 0.01
local S = obj.track2 * 0.01
local ar = -S / (B * B)
local br = ar * (-2 * C)
local cr = ar * (C * C - B * B)
obj.effect("ぼかし", "範囲", obj.track3, "サイズ固定", 1)
T_Color_Module.SetToneCurve(0, 0, 0, ar, br, cr, 0, 0, 0)
T_Color_Module.SetToneCurve(1, 0, 0, ar, br, cr, 0, 0, 0)
T_Color_Module.SetToneCurve(2, 0, 0, ar, br, cr, 0, 0, 0)
local userdata, w, h = obj.getpixeldata()
T_Color_Module.SimToneCurve(userdata, w, h, 0)
obj.putpixeldata(userdata)
