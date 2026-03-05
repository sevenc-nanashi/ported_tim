--label:tim2\T_Color_Module.anm\ネオン
---$track:輝度中心
---min=-200
---max=200
---step=0.1
local rename_me_track0 = 0

---$track:輝度範囲
---min=1
---max=500
---step=0.1
local rename_me_track1 = 10

---$track:強度
---min=0
---max=500
---step=0.1
local rename_me_track2 = 100

---$track:ぼかし
---min=0
---max=500
---step=0.1
local rename_me_track3 = 5

require("T_Color_Module")
local C = rename_me_track0 / 100 + 0.5
local B = rename_me_track1 * 0.01
local S = rename_me_track2 * 0.01
local ar = -S / (B * B)
local br = ar * (-2 * C)
local cr = ar * (C * C - B * B)
obj.effect("ぼかし", "範囲", rename_me_track3, "サイズ固定", 1)
T_Color_Module.SetToneCurve(0, 0, 0, ar, br, cr, 0, 0, 0)
T_Color_Module.SetToneCurve(1, 0, 0, ar, br, cr, 0, 0, 0)
T_Color_Module.SetToneCurve(2, 0, 0, ar, br, cr, 0, 0, 0)
local userdata, w, h = obj.getpixeldata()
T_Color_Module.SimToneCurve(userdata, w, h, 0)
obj.putpixeldata(userdata)
