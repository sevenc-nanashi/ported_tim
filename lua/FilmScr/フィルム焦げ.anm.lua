--label:tim2
--track0:焼け,0,200,30
--track1:輪郭ﾎﾞｶｼ,0,100,35
--track2:燃焼半径,0,5000,50
--track3:乱数,0,10000

--value@kei:発火点集中,50
--value@col:燃焼色/col,0x000000
--value@fibl:燃焼ぼかし(%),5
--value@porn:位置ズレ(%),5
--value@lst:淵発光,300
--value@lsig:淵発光拡散(%),7.5
--check0:淵発光,0;

local burn = obj.track0 * 0.01
local blur = obj.track1 * 0.01
local fiR = obj.track2 * 0.01
local seed = obj.track3
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

if obj.check0 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.effect("ライト", "強さ", lst, "拡散", dw * lsig, "逆光", 1)
    obj.draw()
    obj.load("tempbuffer")
end
