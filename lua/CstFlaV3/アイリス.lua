--label:tim2\光効果\カスタムフレア.anm
---$track:形状
---min=1
---max=14
---step=1
local track_shape = 1

---$track:数
---min=1
---max=100
---step=1
local track_count = 4

---$track:サイズ％
---min=0
---max=5000
---step=0.1
local track_size_percent = 30

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 50

---$value:サイズ幅％
local dsize = 50

---$check:順次拡大
local biger = 0

---$value:強度幅％
local dalp = 5

---$check:ベースカラー
local basechk = 1

---$color:色
local col = 0xccccff

---$value:色幅％
local dcol = 5

---$value:位置％
local PP = { 0, 5 }

---$value:位置オフセット
local OFSET = { 0, 0, 0 }

---$value:散らばり％
local SIG = { 100, 25 }

---$value:回転
local KAITEN = { 0, 0 }

---$check:ｱﾝｶｰに合わせる
local acr = 0

---$value:ぼかし
local blur = 10

---$value:点滅
local blink = 0.2

---$value:乱数シード
local seed = 0

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
local tim2_images = obj.module("tim2")
if basechk == 1 then
    col = CustomFlareColor
end
local fig = track_shape
local count = track_count
local size = track_size_percent * 0.01
local alp = track_intensity * 0.01
local t = PP[1] * 0.01
local dt = PP[2]
local sp = SIG[1] * 0.01
local dsp = SIG[2]
local rot = KAITEN[1]
local drot = KAITEN[2] * 0.5
OFSET[1] = OFSET[1] * 0.01
OFSET[2] = OFSET[2] * 0.01
OFSET[3] = OFSET[3] * 0.01
local data, w, h = tim2_images.custom_flare_load_image("I" .. fig)
obj.putpixeldata("object", data, w, h)
tim2_images.custom_flare_free_image(data)
obj.effect("グラデーション", "color", col, "color2", col, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
local OF = math.floor(obj.time * obj.framerate)
for i = 1, count do
    if dcol > 0 then
        local data, w, h = tim2_images.custom_flare_load_image("I" .. fig)
        obj.putpixeldata("object", data, w, h)
        tim2_images.custom_flare_free_image(data)
        local h, s, v = HSV(col)
        h = math.floor(h + math.floor(3.6 * obj.rand(0, dcol, i, seed))) % 360
        col = HSV(h, s, v)
        obj.effect("グラデーション", "color", col, "color2", col, "blend", 5)
        obj.effect("ぼかし", "範囲", blur)
    end
    local hi = ((i - 0.5) / count - 0.5) * (1 + obj.rand(-dsp, dsp, i, 1000 + seed) * 0.01)
    hi = t + hi * sp
    local ox = CustomFlaredX * (hi + obj.rand(-dt, dt, i, 2000 + seed) * 0.005 + OFSET[1])
    local oy = CustomFlaredY * (hi + obj.rand(-dt, dt, i, 3000 + seed) * 0.005 + OFSET[2])
    local oz = CustomFlaredZ * (hi + obj.rand(-dt, dt, i, 4000 + seed) * 0.005 + OFSET[3])
    local zoom = CustomFlaredX * CustomFlaredX + CustomFlaredY * CustomFlaredY + CustomFlaredZ * CustomFlaredZ
    if zoom == 0 or biger == 0 then
        zoom = 1
    else
        zoom = math.sqrt(
            (
                (CustomFlaredX + ox) * (CustomFlaredX + ox)
                + (CustomFlaredY + oy) * (CustomFlaredY + oy)
                + (CustomFlaredZ + oz) * (CustomFlaredZ + oz)
            )
                / zoom
                * 0.25
        )
    end
    ox = CustomFlareCX + ox
    oy = CustomFlareCY + oy
    oz = CustomFlareCZ + oz
    zoom = zoom * size * (1 - obj.rand(0, dsize, i, 5000 + seed) * 0.01)
    local alpha = obj.rand(0, 100, i, OF + seed) / 100 + (1 - blink)
    if alpha > 1 then
        alpha = 1
    end
    alpha = alp * alpha * obj.rand(100 - dalp * 0.5, 100 + dalp * 0.5, i, 6000 + seed) * 0.01
    local rz = rot + obj.rand(-drot, drot, i, 7000 + seed)
    if acr == 1 then
        rz = rz + math.deg(math.atan2(CustomFlaredY, CustomFlaredX))
    end
    obj.draw(ox, oy, oz, zoom, alpha, 0, 0, rz)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
