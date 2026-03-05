--label:tim2\カスタムフレア.anm\コースティック
---$track:サイズ
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 200

---$track:強度
---min=0
---max=100
---step=0.1
local rename_me_track1 = 20

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local rename_me_track2 = 5

---$value:ベースカラー/chk
local basechk = 1

---$value:色/col
local col = 0xccccff

---$value:位置％
local t = 100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$value:最大半径
local Rmax = 400

---$value:点滅
local blink = 0.2

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = rename_me_track0
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * rename_me_track1 * 0.01
local blur = rename_me_track2
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
