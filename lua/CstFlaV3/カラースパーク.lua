--label:tim2\カスタムフレア.anm\カラースパーク
--track0:サイズ,0,5000,400
--track1:長さ,0,1000,100
--track2:強度,0,100,60
--track3:回転,-3600,3600,0
--value@n:数,100
--value@fig:カラーパターン[1-5],1
--value@dH:幅比率％,5
--value@blur:ぼかし,5
--value@rblur:放射ブラー,5
--value@t:位置％,-100
--value@OFSET:位置オフセット％,{0,0,0}
--value@drh:動径方向バラツキ％,100
--value@blink:点滅,0.2
--value@seed:乱数シード,1
local figmax = 5
obj.copybuffer("cache:BKIMG", "obj") --背景をBKIMGに保存
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
local size = obj.track0 * 0.5
local dL = obj.track1 * 0.5
alpha = alpha * obj.track2 * 0.01
local rot = obj.track3
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
obj.load("image", obj.getinfo("script_path") .. "CF-image\\leafc" .. fig .. ".png")
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
