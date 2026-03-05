--label:tim2\カスタムフレア.anm\ストリーク
--track0:光芒長,0,2000,400
--track1:光芒高さ,0,2000,20
--track2:強度,0,100,50
--track3:回転,-3600,3600,0
--value@basechk:ベースカラー/chk,1
--value@col:光芒色/col,0x9999ff
--value@t:位置％,-100
--value@OFSET:位置オフセット％,{0,0,0}
--value@acr:ｱﾝｶｰに合わせる/chk,0
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
alpha = alpha * obj.track2 * 0.01
local l = obj.track0 * 2
local r = obj.track1 * 0.5
local rot = -obj.track3 / 180 * math.pi
if acr == 1 then
    rot = rot - math.atan2(CustomFlaredY, CustomFlaredX)
end
obj.load("figure", "円", col, r)
obj.effect("ぼかし", "範囲", r / 2.5)
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
local a = alpha
local yr = r
local c = math.cos(rot)
local s = math.sin(rot)
for i = 1, 3 do
    local x0, y0 = -l * c - yr * s + dx, l * s - yr * c + dy
    local x1, y1 = -l * c + yr * s + dx, l * s + yr * c + dy
    local x2, y2 = l * c + yr * s + dx, -l * s + yr * c + dy
    local x3, y3 = l * c - yr * s + dx, -l * s - yr * c + dy
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, a)
    a = a / 2
    yr = yr * 2
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
