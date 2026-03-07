--label:tim2\光効果\カスタムフレア.anm
---$track:光芒長
---min=0
---max=2000
---step=0.1
local track_ray_length = 400

---$track:光芒高さ
---min=0
---max=2000
---step=0.1
local track_ray_height = 5

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 100

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$check:ベースカラー
local basechk = 1

---$color:光芒色
local col = 0x9999ff

---$track:本数
---min=1
---max=5000
---step=1
local n = 3

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$track:拡大率
---min=0
---max=1000
---step=0.1
local exp = 50

---$track:間隔
---min=0
---max=1000
---step=0.1
local dh = 5

---$track:間隔ランダム
---min=0
---max=1000
---step=0.1
local ddh = 5

---$track:横ランダム
---min=0
---max=1000
---step=0.1
local dw = 10

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.1

obj.copybuffer("cache:BKIMG", "obj") --背景をBKIMGに保存
if basechk == 1 then
    col = CustomFlareColor
end
local l = track_ray_length * 2
local r = track_ray_height * 0.5
local rot = track_rotation
exp = exp * 0.01
obj.load("figure", "円", col, r)
obj.effect("ぼかし", "範囲", r / 2.5)
obj.setoption("blend", 0)
obj.setoption("drawtarget", "tempbuffer", 2 * l, 8 * r)
local a = 1
local yr = r
for i = 1, 3 do
    obj.drawpoly(-l, -yr, 0, -l, yr, 0, l, yr, 0, l, -yr, 0, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h)
    --a = a/2
    yr = yr * 2
end
obj.load("tempbuffer")
obj.copybuffer("tmp", "cache:BKIMG")
obj.setoption("blend", CustomFlareMode)
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
local cos = math.cos(rot * math.pi / 180)
local sin = math.sin(-rot * math.pi / 180)
local of = obj.time * obj.framerate
for i = 0, n - 1 do
    local alpha = obj.rand(0, 100, i, of) / 100 + (1 - blink)
    if alpha > 1 then
        alpha = 1
    end
    alpha = alpha * track_intensity * 0.01
    local ox = obj.rand(-dw, dw, i, 1000) * 0.5
    local oy = (i - (n - 1) * 0.5) * dh + obj.rand(-ddh, ddh, i, 2000) * 0.5
    ox, oy = cos * ox + sin * oy, -sin * ox + cos * oy
    obj.draw(ox + dx, oy + dy, dz, exp, alpha, 0, 0, rot)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
