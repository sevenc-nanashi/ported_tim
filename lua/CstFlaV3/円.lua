--label:tim2\カスタムフレア.anm\円
--track0:サイズ,0,5000,300
--track1:強度,0,100,50
--track2:ぼかし％,0,100,10
--track3:位置％,-5000,5000,0
--value@basechk:ベースカラー/chk,1
--value@col:色/col,0xccccff
--value@OFSET:位置ズレ％,{0,0,0}
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
alpha = alpha * obj.track1 * 0.01
local size = obj.track0
local blur = obj.track2
local t = obj.track3 * 0.01
obj.load("figure", "円", col, 100)
obj.effect("ぼかし", "範囲", blur)
ox = CustomFlareCX + t * CustomFlaredX + OFSET[1] * CustomFlaredX * 0.01
oy = CustomFlareCY + t * CustomFlaredY + OFSET[2] * CustomFlaredY * 0.01
oz = CustomFlareCZ + t * CustomFlaredZ + OFSET[3] * CustomFlaredZ * 0.01
obj.draw(ox, oy, oz, size / 100, alpha)
obj.load("tempbuffer")
obj.setoption("blend", 0)
