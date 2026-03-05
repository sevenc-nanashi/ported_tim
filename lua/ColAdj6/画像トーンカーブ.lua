--label:tim2\T_Color_Module.anm\画像トーンカーブ
---$track:X or R
---min=-10000
---max=10000
---step=0.1
local rename_me_track0 = 0

---$track:Y or θ
---min=-10000
---max=10000
---step=0.1
local rename_me_track1 = 0

---$track:角度
---min=-3600
---max=3600
---step=0.1
local rename_me_track2 = 0

---$track:幅％
---min=1
---max=500
---step=0.1
local rename_me_track3 = 100

---$value:中心
local CC = { 0, 0 }

---$color:線色
local col = 0xff0000

---$check:線を非表示
local Lck = 0

---$check:極座標移動
local rename_me_check0 = true

col = col or 0x0
obj.setanchor("CC", 1)
require("T_Color_Module")
local CSET = rename_me_track0
local userdata, w, h = obj.getpixeldata()
local X, Y = rename_me_track0, rename_me_track1
local Deg = rename_me_track2
if rename_me_check0 then
    Deg = Deg + Y
    X, Y = -X * math.sin(Y / 180 * math.pi), X * math.cos(Y / 180 * math.pi)
end
X, Y = X + CC[1], Y + CC[2]
T_Color_Module.ImageToneCurve(userdata, w, h, X, Y, Deg, w * rename_me_track3 * 0.01, col, Lck)
obj.putpixeldata(userdata)
T_ToneCurve_R = 1
T_ToneCurve_G = 1
T_ToneCurve_B = 1
