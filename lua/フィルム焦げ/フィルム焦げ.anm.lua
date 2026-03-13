--label:tim2\加工
---$track:焼け
---min=0
---max=200
---step=0.1
local track_burn = 30

---$track:輪郭ぼかし
---min=0
---max=100
---step=0.1
local track_contour_blur = 35

---$track:燃焼半径
---min=0
---max=5000
---step=0.1
local track_radius = 50

---$track:乱数
---min=0
---max=10000
---step=0.1
local track_random_seed = 0

---$track:発火点集中
---min=0
---max=1000
---step=0.1
local kei = 50

---$color:燃焼色
local col = 0x000000

---$track:燃焼ぼかし(%)
---min=0
---max=100
---step=0.1
local fibl = 5

---$track:位置ズレ(%)
---min=0
---max=100
---step=0.1
local porn = 5

---$track:縁発光
---min=0
---max=1000
---step=1
local lst = 300

---$track:縁発光拡散(%)
---min=0
---max=100
---step=0.1
local lsig = 7.5

---$check:縁発光
local glow_edge = false

local burn = track_burn * 0.01
local blur = track_contour_blur * 0.01
local fiR = track_radius * 0.01
local seed = track_random_seed
kei = kei * 0.001
porn = porn * 0.01
fibl = fibl * 0.01
lsig = lsig * 0.01

-- NOTE: AviUtl2では、alpha_subを複数回かけるとバグるため、マスクのバッファを作ってそこに描画してから合成する

obj.copybuffer("cache:original", "object")

local w, h = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", w, h)

dw = math.max(w, h)
dr = fiR * dw
dd = dw * porn

obj.load("figure", "円", 0xffffff, 100)
obj.effect("ぼかし", "範囲", 100 * blur)

for i = -5, 5 do
    for j = -5, 5 do
        size = (burn + obj.rand(-500, 0, i, j + seed) * 0.001 + 0.5 * math.exp(-kei * (i * i + j * j)) - 0.5) * dr
        if size < 0 then
            size = 0
        end
        dx = obj.rand(-dd, dd, i, j + 1000 + seed)
        dy = obj.rand(-dd, dd, i, j + 2000 + seed)
        obj.draw(i * dw * 0.1 + dx, j * dw * 0.1 + dy, 0, size * 0.01)
    end
end

obj.copybuffer("cache:mask", "tempbuffer")
obj.copybuffer("tempbuffer", "cache:original")
obj.copybuffer("object", "cache:mask")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", "none")
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.effect("縁取り", "サイズ", 1, "ぼかし", fibl * dw, "color", col)
obj.draw()
obj.load("tempbuffer")

if glow_edge then
    -- AviUtl2では逆光で縁が光ってしまうため、領域拡張+クリッピングで光る部分を外に出す
    local size = dw * lsig
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.effect("領域拡張", "塗りつぶし", 1, "上", size, "下", size, "左", size, "右", size)
    obj.effect("ライト", "強さ", lst, "拡散", dw * lsig, "逆光", 1)
    obj.effect("クリッピング", "上", size, "下", size, "左", size, "右", size)
    obj.draw()
    obj.load("tempbuffer")
end
