--label:tim2\カスタムフレア.anm\スパイク
--track0:長さ,0,3000,230
--track1:数,0,5000,50,1
--track2:強度,0,200,40
--track3:回転,-3600,3600,0
--value@basechk:ベースカラー/chk,1
--value@col:光芒色/col,0x9999ff
--value@dH0:幅比率％,8
--value@hrnd:高さランダム％,50
--value@blur:ぼかし,5
--value@spdeg:ステップ角度,0
--value@ddeg:誤差角度,360
--value@t:位置％,-100
--value@OFSET:位置オフセット％,{0,0,0}
--value@fig:形状[1-4],1
--value@blink:点滅,0.2
--value@seed:乱数シード,0
local figmax = 4
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local dL0 = obj.track0 * 0.5
local n = obj.track1
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * obj.track2 * 0.02
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
    local rz = math.rad(i * spdeg + obj.rand(-ddeg, ddeg, i, 1000 + seed) - obj.track3)
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
