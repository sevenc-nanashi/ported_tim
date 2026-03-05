--label:tim2\T_Color_Module.anm\粒状化
---$track:量
---min=0
---max=100
---step=0.1
local rename_me_track0 = 50

---$track:ｺﾝﾄﾗｽﾄ
---min=-400
---max=400
---step=0.1
local rename_me_track1 = 100

---$track:シード
---min=1
---max=10000
---step=1
local rename_me_track2 = 1

---$track:処理法
---min=1
---max=3
---step=1
local rename_me_track3 = 1

---$color:色1
local col1 = 0xffffff

---$color: 色2
local col2 = 0x0

---$check:時間変動
local rename_me_check0 = true

local N = rename_me_track2
if rename_me_check0 then
    N = obj.rand(0, 10000, -obj.time * obj.framerate, 1)
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.grainy(userdata, w, h, rename_me_track0, rename_me_track1, rename_me_track3, N, col1, col2)
obj.putpixeldata(userdata)
