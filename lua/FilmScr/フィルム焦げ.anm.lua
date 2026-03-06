--label:tim2\加工
---$track:焼け
---min=0
---max=200
---step=0.1
local track_burn = 30

---$track:輪郭ﾎﾞｶｼ
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

---$value:発火点集中
local kei = 50

---$color:燃焼色
local col = 0x000000

---$value:燃焼ぼかし(%)
local fibl = 5

---$value:位置ズレ(%)
local porn = 5

---$value:淵発光
local lst = 300

---$value:淵発光拡散(%)
local lsig = 7.5

---$check:淵発光
local check0 = false

local burn = track_burn * 0.01
local blur = track_contour_blur * 0.01
local fiR = track_radius * 0.01
local seed = track_random_seed
kei = kei * 0.001
porn = porn * 0.01
fibl = fibl * 0.01
lsig = lsig * 0.01

local w, h = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()

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
        obj.setoption("blend", "alpha_sub")
        dx = obj.rand(-dd, dd, i, j + 1000 + seed)
        dy = obj.rand(-dd, dd, i, j + 2000 + seed)
        obj.draw(i * dw * 0.1 + dx, j * dw * 0.1 + dy, 0, size * 0.01)
    end
end

obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.effect("縁取り", "サイズ", 1, "ぼかし", fibl * dw, "color", col)
obj.draw()
obj.load("tempbuffer")

if check0 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.effect("ライト", "強さ", lst, "拡散", dw * lsig, "逆光", 1)
    obj.draw()
    obj.load("tempbuffer")
end
