--label:tim2\カスタムフレア.anm\コースティック
--track0:サイズ,0,5000,200
--track1:強度,0,100,20
--track2:ぼかし,0,1000,5
--value@basechk:ベースカラー/chk,1
--value@col:色/col,0xccccff
--value@t:位置％,100
--value@OFSET:位置オフセット％,{0,0,0}
--value@Rmax:最大半径,400
--value@blink:点滅,0.2
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = obj.track0
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * obj.track1 * 0.01
local blur = obj.track2
obj.load("image", obj.getinfo("script_path") .. "CF-image\\ctc1.png")
obj.effect("グラデーション", "color", col, "color2", col, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
local ox = (t + OFSET[1]) * 0.01 * CustomFlaredX
local oy = (t + OFSET[2]) * 0.01 * CustomFlaredY
local oz = (t + OFSET[3]) * 0.01 * CustomFlaredZ
local zz = Rmax * Rmax - oy * oy - ox * ox
local s1, s2
if zz > 0 then
    zz = math.sqrt(zz)
    local rr = math.sqrt(zz * zz + oy * oy)
    if math.abs(ox) * 10000 > rr then
        s1 = math.atan2(ox, rr) / math.pi * 180
        s2 = math.atan2(oy, zz) / math.pi * 180
        ox = CustomFlareCX + ox
        oy = CustomFlareCY + oy
        oz = CustomFlareCZ + oz
    else
        ox, oy, oz, alpha, s1, s2 = 0, 0, 0, 0, 0, 0
    end
else
    ox, oy, oz, alpha, s1, s2 = 0, 0, 0, 0, 0, 0
end
obj.draw(ox, oy, oz, size / 200, alpha, s2, -s1, 0)
obj.load("image", obj.getinfo("script_path") .. "CF-image\\ctc2.png")
obj.effect("グラデーション", "color", col, "color2", col, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
local k = 30
for i = 0, k - 1 do
    local ds = i / k
    obj.draw(
        ox + ds * CustomFlaredX * 0.5,
        oy + ds * CustomFlaredY * 0.5,
        oz + ds * CustomFlaredZ * 0.5,
        (1 - ds) * size / 200,
        3 * alpha / k,
        s2,
        -s1,
        0
    )
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
