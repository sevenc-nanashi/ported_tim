--label:tim2\未分類
---$track:半径
---min=1
---max=500
---step=1
local track_radius = 1

---$track:強度
---min=0
---max=1000
---step=0.1
local track_intensity = 300

---$track:粒子化幅
---min=0
---max=1000
---step=1
local track_width = 0

---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 0

---$color:ライン色
local col1 = 0xff0000

---$color:背景色
local col2 = 0xffffff

---$value:背景透明度
local Bal = 0

---$value:ｵﾘｼﾞﾅﾙ透明度
local Oal = 100

---$check:輝度反転
local Lr = 0

---$check:粒子[移動/参照]
local par = 0

---$value:└飛散方向
local dir = { 0, 360 }

---$check:└飛散ループ
local dck = 1

---$value:追加領域サイズ
local arc = 0

---$value:シード
local seed = 0

---$value:└変化間隔
local sR = 0

---$check:ラインのみ
local check0 = false

dir = dir or { 0, 360 }
seed = seed or 0
if sR > 0 then
    seed = seed + math.floor(obj.time * obj.framerate / sR)
end
require("T_LineExtra_Module")
if Lr == 1 then
    obj.effect("反転", "輝度反転", 1)
end
if arc > 0 then
    arc = (arc + 1) / 2
    obj.effect("領域拡張", "上", arc, "下", arc, "右", arc, "左", arc)
end
local userdata, w, h = obj.getpixeldata()
T_LineExtra_Module.SetPublicImage(userdata, w, h)
obj.effect("ぼかし", "範囲", track_radius, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata()
T_LineExtra_Module.LineExt(
    userdata,
    w,
    h,
    track_intensity,
    track_width,
    track_threshold,
    check0,
    Bal,
    Oal,
    col1,
    col2,
    par,
    dck,
    dir[1],
    dir[2],
    seed
)
obj.putpixeldata(userdata)
