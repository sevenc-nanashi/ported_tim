--label:tim2\カスタムフレア.anm\ゆらめき
--track0:サイズ,10,1000,250
--track1:光芒量,0,100,55
--track2:強度,0,200,60
--track3:回転,-3600,3600,0
--value@basechk:ベースカラー/chk,1
--value@col:光芒色/col,0x9999ff
--value@t:位置％,-100
--value@OFSET:位置オフセット％,{0,0,0}
--value@rnd:先端ぼかし％,100
--value@speed:光芒変化速度,0.2
--value@fig:形状[1-8],5
--value@clp:ｸﾘｯﾌﾟ位置幅ﾎﾞｶｼ,{0,0,0}
--value@aub:ｸﾘｯﾌﾟ向き/chk,0
--value@blink:点滅,0.1
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
local w = obj.track0
local c_num = obj.track1
local c_alp = obj.track2 * 0.01
fig = math.floor(fig)
if fig > 8 then
    fig = 8
end
if fig < 1 then
    fig = 1
end
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
local r = 2 * w
obj.load("figure", "四角形", col, r)
if fig <= 4 then
    obj.effect("ノイズ", "type", fig, "周期X", 1, "周期Y", 0, "しきい値", 100 - c_num, "速度Y", -speed)
else
    fig = fig - 4
    obj.effect("ノイズ", "type", fig, "周期X", c_num * 0.05, "周期Y", 0, "しきい値", 0, "速度Y", -speed)
end
obj.effect("境界ぼかし", "範囲", r * rnd * 0.01, "縦横比", -100)
clp[1] = -r * (clp[1] / 360 % 1)
clp[2] = r * (clp[2] / 360 % 1)
if aub == 1 then
    clp[1] = -r * (math.atan2(CustomFlaredY, CustomFlaredX) * 0.5 + math.pi / 4) / math.pi
end
if clp[2] > 0 then
    obj.effect("斜めクリッピング", "角度", 90, "中心X", clp[1] - r, "幅", -clp[2], "ぼかし", clp[3])
    obj.effect("斜めクリッピング", "角度", 90, "中心X", clp[1], "幅", -clp[2], "ぼかし", clp[3])
    obj.effect("斜めクリッピング", "角度", 90, "中心X", clp[1] + r, "幅", -clp[2], "ぼかし", clp[3])
end
r = r / 2.5
obj.effect("クリッピング", "上", r)
obj.effect("極座標変換", "回転", obj.track3)
local x0 = -r + dx
local y0 = -r + dy
local x1 = r + dx
local y1 = -r + dy
local x2 = r + dx
local y2 = r + dy
local x3 = -r + dx
local y3 = r + dy
alpha = alpha * c_alp
if alpha <= 1 then
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, alpha)
else
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, 1)
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, alpha - 1)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
