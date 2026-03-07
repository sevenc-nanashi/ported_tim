--label:tim2\光効果\カスタムフレア.anm
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 400

---$track:長さ
---min=0
---max=1000
---step=0.1
local track_length = 100

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 60

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:数
---min=1
---max=5000
---step=1
local n = 100

---$select:カラーパターン
---1=1
---2=2
---3=3
---4=4
---5=5
local fig = 1

---$track:幅比率％
---min=0
---max=100
---step=0.1
local dH = 5

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 5

---$track:放射ブラー
---min=0
---max=1000
---step=0.1
local rblur = 5

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$track:動径方向バラツキ％
---min=0
---max=200
---step=0.1
local drh = 100

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

---$track:乱数シード
---min=0
---max=100000
---step=1
local seed = 1

local figmax = 5
obj.copybuffer("cache:BKIMG", "obj") --背景をBKIMGに保存
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
local size = track_size * 0.5
local dL = track_length * 0.5
alpha = alpha * track_intensity * 0.01
local rot = track_rotation
drh = drh * 0.01
fig = math.floor(fig)
if fig > figmax then
    fig = figmax
end
if fig < 1 then
    fig = 1
end
dH = dL * dH * 0.01
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
local tim2_images = obj.module("tim2")
local data, w, h = tim2_images.custom_flare_load_image("leafc" .. fig)
obj.putpixeldata("object", data, w, h)
tim2_images.custom_flare_free_image(data)
obj.effect("ぼかし", "範囲", blur)
local w0, h0 = obj.getpixel()
local LS = dL
local LL = math.max(size * 0.5, dL)
dH = w0 * dH / 30
dL = h0 * dL / 100
local wh = 2 * (dL + LL)
obj.setoption("drawtarget", "tempbuffer", wh, wh)
obj.setoption("blend", 6)
LS = drh * LS + (1 - drh) * LL
for i = 1, n do
    local rz = (obj.rand(-3600, 3600, i, seed) * 0.1 - rot) * math.pi / 180
    local r = obj.rand(LS, LL, i, 1000 + seed)
    local s = math.sin(rz)
    local c = math.cos(rz)
    local x0 = -dH
    local y0 = -dL + r
    local x1 = dH
    local y1 = -dL + r
    local x2 = dH
    local y2 = dL + r
    local x3 = -dH
    local y3 = dL + r
    x0, y0 = x0 * c + y0 * s, -x0 * s + y0 * c
    x1, y1 = x1 * c + y1 * s, -x1 * s + y1 * c
    x2, y2 = x2 * c + y2 * s, -x2 * s + y2 * c
    x3, y3 = x3 * c + y3 * s, -x3 * s + y3 * c
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, alpha)
end
obj.load("tempbuffer")
obj.effect("放射ブラー", "範囲", rblur)
obj.copybuffer("tmp", "cache:BKIMG")
obj.setoption("blend", CustomFlareMode)
obj.draw(dx, dy, dz)
obj.load("tempbuffer")
obj.setoption("blend", 0)
