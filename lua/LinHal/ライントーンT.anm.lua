--label:tim2
--track0:分割数,10,500,80
--track1:ﾗｲﾝ細％,0,100,10
--track2:ﾗｲﾝ太％,0,100,60
--track3:シフト,-10000,10000,0
--value@Lcol:ライン色/col,"0x000000"
--value@Bcol:背景色/col,"0xffffff"
--value@bkap:背景色非表示/chk,0
--value@bai:横分割倍率%,200
--value@rev:反転/chk,0

local spN = obj.track0
local spM = math.floor(spN * bai * 0.01)
local tsi1 = obj.track1 * 0.01
local tsi2 = math.max(obj.track2 - obj.track1, 0) * 0.01
local sf = obj.track3

local w, h = obj.getpixel()
local w2, h2 = w * 0.5, h * 0.5
local sw = w / spM
local sh = h / spN
sf = sf % sh
obj.copybuffer("cache:ori_img", "obj")

obj.pixeloption("type", "yc")
Ldata = {}
for i = 0, spM - 1 do
    Ldata[i] = {}
    for j = -1, spN do
        local y, cb, cr, a = obj.getpixel((i + 0.5) * sw, (j + 0.5) * sh + sf, "yc")
        Ldata[i][j] = y / 4096
    end
end
if rev == 0 then
    for i = 0, spM - 1 do
        for j = -1, spN do
            Ldata[i][j] = 1 - Ldata[i][j]
        end
    end
end
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("figure", "四角形", Lcol, 1)
obj.setoption("blend", "alpha_add")
for i = 0, spM - 1 do
    for j = -1, spN do
        local x1 = i * sw - w2
        local y = (j + 0.5) * sh - h2 + sf
        local dy = sh * (tsi1 + Ldata[i][j] * tsi2) * 0.5
        local x2 = x1 + sw
        local y1 = y - dy
        local y2 = y + dy
        obj.drawpoly(x1, y1, 0, x2, y1, 0, x2, y2, 0, x1, y2, 0)
    end
end
--間を綺麗に詰めるために少し複雑な描画
if bkap == 0 then
    obj.copybuffer("cache:Line_img", "tmp")
    obj.load("figure", "四角形", Bcol, 1)
    obj.drawpoly(-w2, -h2, 0, w2, -h2, 0, w2, h2, 0, -w2, h2, 0)
    obj.setoption("blend", 0)
    obj.draw()
    obj.copybuffer("obj", "cache:Line_img")
    obj.draw()
end

obj.copybuffer("obj", "cache:ori_img")
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", 0)
