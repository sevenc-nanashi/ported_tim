--label:tim2\カスタムフレア.anm\アイリス(単)
--track0:形状,1,14,1,1
--track1:サイズ％,0,5000,30
--track2:強度,0,100,50
--track3:ぼかし,0,1000,5
--value@basechk:ベースカラー/chk,1
--value@col:色/col,0xccccff
--value@t:位置％,0
--value@OFSET:位置ズレ％,{0,0,0}
--value@rot:回転,0
--value@acr:ｱﾝｶｰに合わせる/chk,0
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
local fig = obj.track0
local size = obj.track1 * 0.01
local blur = obj.track3
t = t * 0.01
obj.load("image", obj.getinfo("script_path") .. "CF-image\\I" .. fig .. ".png")
obj.effect("グラデーション", "color", col, "color2", col, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
ox = CustomFlareCX + t * CustomFlaredX + OFSET[1] * CustomFlaredX * 0.01
oy = CustomFlareCY + t * CustomFlaredY + OFSET[2] * CustomFlaredY * 0.01
oz = CustomFlareCZ + t * CustomFlaredZ + OFSET[3] * CustomFlaredZ * 0.01
if acr == 1 then
    rot = rot + math.deg(math.atan2(CustomFlaredY, CustomFlaredX))
end
obj.draw(ox, oy, oz, size, alpha, 0, 0, rot)
obj.load("tempbuffer")
obj.setoption("blend", 0)
