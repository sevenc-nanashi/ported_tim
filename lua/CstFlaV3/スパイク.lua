--label:tim2\カスタムフレア.anm
---$track:長さ
---min=0
---max=3000
---step=0.1
local rename_me_track0 = 230

---$track:数
---min=0
---max=5000
---step=1
local rename_me_track1 = 50

---$track:強度
---min=0
---max=200
---step=0.1
local rename_me_track2 = 40

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

---$check:ベースカラー
local basechk = 1

---$color:光芒色
local col = 0x9999ff

---$value:幅比率％
local dH0 = 8

---$value:高さランダム％
local hrnd = 50

---$value:ぼかし
local blur = 5

---$value:ステップ角度
local spdeg = 0

---$value:誤差角度
local ddeg = 360

---$value:位置％
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$value:形状[1-4]
local fig = 1

---$value:点滅
local blink = 0.2

---$value:乱数シード
local seed = 0

local figmax = 4
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local dL0 = rename_me_track0 * 0.5
local n = rename_me_track1
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * rename_me_track2 * 0.02
dH0 = dL0 * dH0 * 0.01
ddeg = ddeg * 0.5
fig = math.floor(fig)
if fig > figmax then
    fig = figmax
end
if fig < 1 then
    fig = 1
end
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
obj.load("image", obj.getinfo("script_path") .. "CF-image\\spike" .. fig .. ".png")
obj.effect("グラデーション", "color", col, "color2", col, "blend", 3)
obj.effect("ぼかし", "範囲", blur)
local w0, h0 = obj.getpixel()
local rz = {}
for i = 1, n do
    local rnd = obj.rand(100 - hrnd, 100, i, seed) * 0.01
    local dH = dH0 * rnd
    local dL = dL0 * rnd
    dH = w0 * dH / 30
    dL = h0 * dL / 100
    local rz = math.rad(i * spdeg + obj.rand(-ddeg, ddeg, i, 1000 + seed) - rename_me_track3)
    local r = dL
    local s = math.sin(rz)
    local c = math.cos(rz)
    local Lr1 = dL + r
    local Lr2 = -dL + r
    local x0, y0 = -dH * c + Lr1 * s + dx, dH * s + Lr1 * c + dy
    local x1, y1 = dH * c + Lr1 * s + dx, -dH * s + Lr1 * c + dy
    local x2, y2 = dH * c + Lr2 * s + dx, -dH * s + Lr2 * c + dy
    local x3, y3 = -dH * c + Lr2 * s + dx, dH * s + Lr2 * c + dy
    local rp = math.floor(alpha)
    local md = alpha - rp
    for i = 1, rp do
        obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, 1)
    end
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, md)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
