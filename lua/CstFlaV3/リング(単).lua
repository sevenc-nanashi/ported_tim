--label:tim2\カスタムフレア.anm\リング(単)
--track0:サイズ,0,5000,200
--track1:幅,0,4000,10
--track2:強度,0,100,50
--track3:ぼかし,0,1000,10
--value@basechk:ベースカラー/chk,1
--value@col:色/col,0xccccff
--value@dt:位置％,0
--value@OFSET:位置オフセット,{0,0,0}
--value@blink:点滅,0.2
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
local size = obj.track0
local haba = obj.track1
local blur = obj.track3
dt = dt * 0.01
obj.load("figure", "円", col, size, haba)
obj.effect("ぼかし", "範囲", blur)
ox = CustomFlareCX + dt * CustomFlaredX + OFSET[1] * CustomFlaredX * 0.01
oy = CustomFlareCY + dt * CustomFlaredY + OFSET[2] * CustomFlaredY * 0.01
oz = CustomFlareCZ + dt * CustomFlaredZ + OFSET[3] * CustomFlaredZ * 0.01
obj.draw(ox, oy, oz, 1, alpha)
obj.load("tempbuffer")
obj.setoption("blend", 0)
