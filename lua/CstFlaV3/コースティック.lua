--label:tim2\光効果\カスタムフレア.anm
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 200

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 20

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local track_blur = 5

---$check:ベースカラー
local basechk = 1

---$color:色
local col = 0xccccff

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local t = 100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$track:最大半径
---min=0
---max=5000
---step=0.1
local Rmax = 400

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = track_size
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * track_intensity * 0.01
local blur = track_blur
local tim2_images = obj.module("tim2")
local data, w, h = tim2_images.custom_flare_load_image("ctc1")
obj.putpixeldata("object", data, w, h)
tim2_images.custom_flare_free_image(data)
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
local data, w, h = tim2_images.custom_flare_load_image("ctc2")
obj.putpixeldata("object", data, w, h)
tim2_images.custom_flare_free_image(data)
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
