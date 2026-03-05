--label:tim2\カスタムフレア.anm\ストリーク(複)
--track0:光芒長,0,2000,400
--track1:光芒高さ,0,2000,5
--track2:強度,0,100,100
--track3:回転,-3600,3600,0
--value@basechk:ベースカラー/chk,1
--value@col:光芒色/col,0x9999ff
--value@n:本数,3
--value@t:位置％,-100
--value@OFSET:位置オフセット％,{0,0,0}
--value@exp:拡大率,50
--value@dh:間隔,5
--value@ddh:間隔ﾗﾝﾀﾞﾑ,5
--value@dw:横ﾗﾝﾀﾞﾑ,10
--value@blink:点滅,0.1
obj.copybuffer("cache:BKIMG", "obj") --背景をBKIMGに保存
if basechk == 1 then
    col = CustomFlareColor
end
local l = obj.track0 * 2
local r = obj.track1 * 0.5
local rot = obj.track3
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
    alpha = alpha * obj.track2 * 0.01
    local ox = obj.rand(-dw, dw, i, 1000) * 0.5
    local oy = (i - (n - 1) * 0.5) * dh + obj.rand(-ddh, ddh, i, 2000) * 0.5
    ox, oy = cos * ox + sin * oy, -sin * ox + cos * oy
    obj.draw(ox + dx, oy + dy, dz, exp, alpha, 0, 0, rot)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
