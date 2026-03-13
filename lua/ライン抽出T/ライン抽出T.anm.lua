--label:tim2\抽出
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

---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 0

---$color:ライン色
local col1 = 0xff0000

---$color:背景色
local col2 = 0xffffff

---$track:背景透明度
---min=0
---max=100
---step=1
local bal = 0

---$track:オリジナル透明度
---min=0
---max=100
---step=1
local oal = 100

---$check:輝度反転
local lr = false

---$check:ラインのみ
local line_only = false

---$track:粒子化幅
---min=0
---max=1000
---step=1
local track_width = 0

---$check:粒子[移動/参照]
local par = false

---$track:飛散方向(開始)
---min=0
---max=360
---step=1
local dir_start = 0

---$track:飛散方向(終了)
---min=0
---max=360
---step=1
local dir_end = 360

---$check:飛散ループ
local dck = true

---$track:シード
---min=0
---max=1000000
---step=1
local seed = 0

---$track:シード変化間隔
---min=0
---max=600
---step=1
local seed_interval = 0

---$track:追加領域サイズ
---min=0
---max=500
---step=1
local arc = 0

if seed_interval > 0 then
    seed = seed + math.floor(obj.time * obj.framerate / seed_interval)
end
local tim2 = obj.module("tim2")
if lr then
    obj.effect("反転", "輝度反転", 1)
end
if arc > 0 then
    arc = (arc + 1) / 2
    obj.effect("領域拡張", "上", arc, "下", arc, "右", arc, "左", arc)
end
local userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.lineextra_set_public_image(userdata, w, h)
obj.effect("ぼかし", "範囲", track_radius, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.lineextra_line_ext(
    userdata,
    w,
    h,
    track_intensity,
    track_width,
    track_threshold,
    line_only,
    bal,
    oal,
    col1,
    col2,
    par,
    dck,
    dir_start,
    dir_end,
    seed
)
obj.putpixeldata("object", userdata, w, h, "bgra")
