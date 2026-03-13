--label:tim2\光効果\@カスタムフレア
---$track:密度
---min=1
---max=100
---step=0.1
local track_density = 10

---$track:サイズ％
---min=0
---max=50
---step=0.1
local track_size_percent = 15

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 15

---$track:減衰率
---min=0
---max=100
---step=0.1
local track_attenuation_rate = 40

---$figure:形状
local fig = "円"

---$track:サイズ幅％
---min=0
---max=100
---step=0.1
local dsize = 10

---$track:強度幅％
---min=0
---max=100
---step=0.1
local dalp = 0

---$check:ベースカラー
local basechk = 1

---$color:色
local col = 0xccccff

---$track:色幅％
---min=0
---max=100
---step=0.1
local dcol = 0

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rot = 0

---$track:回転幅
---min=-3600
---max=3600
---step=0.1
local drot = 0

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 0

---$track:乱数シード
---min=0
---max=100000
---step=1
local seed = 0

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = CustomFlareW * track_size_percent * 0.01
local alp = track_intensity * 0.01
local gen = track_attenuation_rate * 0.01
obj.load("figure", fig, col, size)
obj.effect("ぼかし", "範囲", blur)
local countx = math.floor(CustomFlareW / 600 * track_density)
local county = math.floor(CustomFlareH / 600 * track_density)
gen = -200 * gen / (CustomFlareW * CustomFlareW)
local st = CustomFlareW / countx
local dw = st * 0.5
for i = 0, countx do
    for j = 0, county do
        if dcol > 0 then
            local h, s, v = HSV(col)
            h = math.floor(h + math.floor(3.6 * obj.rand(0, dcol, i, j + seed))) % 360
            col = HSV(h, s, v)
            obj.load("figure", fig, col, size)
            obj.effect("ぼかし", "範囲", blur)
        end
        local zoom = 1 - obj.rand(0, dsize, i, j + 4000 + seed) * 0.01
        local alpha = alp * obj.rand(100 - dalp, 100, i, j + 6000 + seed) * 0.01
        local ox = i * st - CustomFlareW * 0.5 + obj.rand(-dw, dw, i, j + 1000 + seed)
        local oy = j * st - CustomFlareH * 0.5 + obj.rand(-dw, dw, i, j + 2000 + seed)
        local rr = (ox - CustomFlareXX) * (ox - CustomFlareXX) + (oy - CustomFlareYY) * (oy - CustomFlareYY)
        alpha = alpha * math.exp(gen * rr)
        local rz = rot + obj.rand(-drot, drot, i, j + 7000 + seed)
        obj.draw(ox, oy, 0, zoom, alpha, 0, 0, rz)
    end
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
