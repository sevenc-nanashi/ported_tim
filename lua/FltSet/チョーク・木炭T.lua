--label:tim2\T_Filter_Module.anm
---$track:木炭適用
---min=0
---max=100
---step=0.1
local rename_me_track0 = 0

---$track:ﾁｭｰｸ適用
---min=0
---max=100
---step=0.1
local rename_me_track1 = 0

---$track:筆圧
---min=0
---max=100
---step=0.1
local rename_me_track2 = 50

---$track:しきい値
---min=0
---max=255
---step=1
local rename_me_track3 = 0

---$value:長さ[1-10]
local len = 7

---$value:ノイズ強度
local np = 30

---$color:シャドウ
local col1 = 0x0

---$color:ハイライト
local col2 = 0xffffff

---$check:シード固定
local sechk = 1

---$value:シード
local seed = 0

---$check:しきい値を自動計算
local rename_me_check0 = true

require("T_Filter_Module")
if sechk == 0 then
    seed = seed + obj.time * obj.framerate
end
if len < 1 then
    len = 1
elseif len > 10 then
    len = 10
end
obj.effect("単色化")
local userdata, w, h = obj.getpixeldata()
T_Filter_Module.Preprocessing(
    userdata,
    w,
    h,
    rename_me_track0 * 0.01,
    rename_me_track1 * 0.01,
    rename_me_track2 * 0.01,
    rename_me_track3,
    rename_me_check0
)
obj.putpixeldata(userdata)
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.effect("単色化", "輝度を保持する", 0)
obj.effect("ノイズ", "強さ", 100, "周期X", 50, "周期Y", 50, "type", 0, "mode", 1, "seed", seed)
obj.effect("ぼかし", "範囲", 3, "サイズ固定", 1)
obj.setoption("blend", 5)
obj.draw(0, 0, 0, 1, np * 0.01)
obj.load("tempbuffer")
userdata, w, h = obj.getpixeldata()
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.ChalkCharcoal(userdata, w, h, len, r1, g1, b1, r2, g2, b2)
obj.putpixeldata(userdata)
obj.setoption("blend", 0)
