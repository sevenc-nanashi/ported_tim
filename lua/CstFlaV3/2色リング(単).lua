--label:tim2\カスタムフレア.anm\2色リング(単)
--track0:サイズ,0,5000,200
--track1:幅,0,4000,20
--track2:強度,0,100,80
--track3:回転,-3600,3600,0
--value@basechk:ベースカラー/chk,0
--value@col1:色1/col,0xff0000
--value@col2:色2/col,0x22ff22
--value@grh:グラデ幅,40
--value@blur:ぼかし,5
--value@ew:開口量％,40
--value@bw:開口ぼかし％,20
--value@t:位置％,25
--value@OFSET:位置オフセット,{0,0,0}
--value@auba:自動消去/chk,0
--value@Rmax:基準距離,400
--value@blink:点滅,0.2
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * obj.track2 * 0.01
if auba == 1 then
    alpha = alpha
        * math.sqrt(CustomFlaredX * CustomFlaredX + CustomFlaredY * CustomFlaredY + CustomFlaredZ * CustomFlaredZ)
        / Rmax
end
local l = obj.track0 * math.pi / 4
local cy = (l - obj.track1 * math.pi) * 0.5
local rot = obj.track3 + math.deg(math.atan2(CustomFlaredY, CustomFlaredX)) - 90
t = t * 0.01
obj.load("figure", "四角形", CustomFlareColor, l)
obj.effect("斜めクリッピング", "角度", -180, "中心Y", cy)
if basechk == 0 then
    obj.effect("グラデーション", "color", col1, "color2", col2, "中心Y", cy / 2 + l / 4, "幅", grh)
end
if ew > 0 then
    obj.effect("斜めクリッピング", "角度", 90, "幅", l * (100 - ew) * 0.01, "ぼかし", l * bw * 0.01)
end
obj.effect("極座標変換")
obj.effect("ぼかし", "範囲", blur)
ox = CustomFlareCX + t * CustomFlaredX + OFSET[1] * CustomFlaredX * 0.01
oy = CustomFlareCY + t * CustomFlaredY + OFSET[2] * CustomFlaredY * 0.01
oz = CustomFlareCZ + t * CustomFlaredZ + OFSET[3] * CustomFlaredZ * 0.01
obj.draw(ox, oy, oz, 1, alpha, 0, 0, rot)
obj.load("tempbuffer")
obj.setoption("blend", 0)
