--label:tim2\カスタムフレア.anm\レンズ軌道
---$track:密度
---min=1
---max=100
---step=0.1
local rename_me_track0 = 10

---$track:サイズ％
---min=0
---max=50
---step=0.1
local rename_me_track1 = 15

---$track:強度
---min=0
---max=100
---step=0.1
local rename_me_track2 = 15

---$track:減衰率
---min=0
---max=100
---step=0.1
local rename_me_track3 = 40

---$figure:形状
local fig = "円"

---$value:サイズ幅％
local dsize = 10

---$value:強度幅％
local dalp = 0

---$check:ベースカラー
local basechk = 1

---$color:色
local col = 0xccccff

---$value:色幅％
local dcol = 0

---$value:回転
local rot = 0

---$value:回転幅
local drot = 0

---$value:ぼかし
local blur = 0

---$value:乱数シード
local seed = 0

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = CustomFlareW * rename_me_track1 * 0.01
local alp = rename_me_track2 * 0.01
local gen = rename_me_track3 * 0.01
obj.load("figure", fig, col, size)
obj.effect("ぼかし", "範囲", blur)
local countx = math.floor(CustomFlareW / 600 * rename_me_track0)
local county = math.floor(CustomFlareH / 600 * rename_me_track0)
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
