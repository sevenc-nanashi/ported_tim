--label:tim2\カスタムオブジェクト\集中線T.obj
---$track:発生量
---min=0
---max=100
---step=0.1
local track_spawn_amount = 35

---$track:中心
---min=0
---max=100
---step=0.1
local track_center = 60

---$track:分布
---min=0
---max=100
---step=0.01
local track_distribution = 50

---$track:放射周期
---min=0
---max=100
---step=0.1
local track_period = 0

---$color:色
local color = 0xffffff

---$value:明るさ
local Gr = 500

---$value:放射速度
local yspd = 0

---$value:変化速度
local spd = 0

---$value:回転速度
local rv = 0

---$value:渦巻
local Edd = 0

---$value:タイプ
local TY = 1

---$value:シード
local seed = 0

---$value:幅
local w = nil

---$value:高さ
local h = nil

local sh = 100 - track_spawn_amount
local clipY = track_center
local fr1 = track_distribution
local yfr = track_period
local screen_w = w or obj.screen_w
local screen_h = h or obj.screen_h

fr1 = fr1 * fr1 * 0.01
yfr = yfr / 25
local size = (screen_w < screen_h) and screen_h or screen_w
clipY = 0.01 * (clipY - 50) * size
obj.load("figure", "四角形", 0xffffff, size)
obj.effect(
    "ノイズ",
    "変化速度",
    spd,
    "周期X",
    fr1,
    "周期Y",
    yfr,
    "速度Y",
    -yspd,
    "しきい値",
    sh,
    "seed",
    seed + 3000,
    "type",
    TY
)
obj.effect("斜めクリッピング", "角度", 180, "ぼかし", size, "中心Y", clipY)
obj.effect("極座標変換", "渦巻", Edd * 0.1, "回転", rv * obj.time)
obj.setoption("drawtarget", "tempbuffer", screen_w, screen_h)
obj.draw(0, 0, 0, 1.2)
obj.load("tempbuffer")
obj.effect("グロー", "強さ", Gr, "拡散", 1, "しきい値", 0, "ぼかし", 1)
obj.effect("単色化", "color", color, "輝度を保持する", 0)
