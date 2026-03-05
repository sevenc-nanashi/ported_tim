--label:tim2
---$track:サイズ
---min=2
---max=1500
---step=1
local rename_me_track0 = 50

---$track:補正
---min=0
---max=1000
---step=1
local rename_me_track1 = 0

---$track:最小ｻｲｽﾞ
---min=2
---max=1500
---step=1
local rename_me_track2 = 10

---$track:ﾓｻﾞｲｸ回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

---$value:背景を透明/chk
local backC = 0

---$value:背景をシャープ/chk
local backS = 0

---$value:凸エッジ/chk
local totsuC = 0

---$value:凸エッジ幅
local totsu1 = 2

---$value:凸エッジ高さ
local totsu2 = 1

---$value:凸エッジ角度
local totsu3 = -45

local draw = obj.draw
local effect = obj.effect

local w, h = obj.getpixel()
local w0, h0 = w, h
local ROT = rename_me_track3 % 360

if ROT ~= 0 then
    local rr = math.rad(ROT)
    local cos = math.abs(math.cos(rr))
    local sin = math.abs(math.sin(rr))
    w, h = w * cos + h * sin, w * sin + h * cos
    obj.setoption("drawtarget", "tempbuffer", w, h)
    draw(0, 0, 0, 1, 1, 0, 0, -ROT)
    obj.load("tempbuffer")
end

local size = rename_me_track0
size = math.max(size, rename_me_track2)
local R = math.max(size - rename_me_track1, 2)
obj.copybuffer("cache:back", "obj")

local L = 0.402963724433828 * size
effect("方向ブラー", "範囲", L, "角度", 0, "サイズ固定", 1)
effect("方向ブラー", "範囲", L, "角度", 90, "サイズ固定", 1)

if backS == 0 then
    obj.copybuffer("cache:back", "obj")
end

local w2 = w * 0.5
local h2 = h * 0.5
local dw = math.sqrt(3) * 0.5 * size
local dh = 1.5 * size

local nx1 = math.floor((w / dw + 1) * 0.5)
local ny1 = math.floor((h / size + 1) / 3)
local nx2 = 2 * math.ceil(0.5 * w / dw)
local ny2 = 2 * math.floor((h / size + 2.5) / 3)
local K1 = (nx2 + 1) * 0.5
local K2 = (ny2 + 1) * 0.5

local CH1 = {}
local A1 = {}
for i = -nx1, nx1 do
    CH1[i] = {}
    A1[i] = {}
    for j = -ny1, ny1 do
        local u = dw * i + w2
        local v = dh * j + h2
        if u < 0 then
            u = 0
        end
        if u > w - 1 then
            u = w - 1
        end
        if v < 0 then
            v = 0
        end
        if v > h - 1 then
            v = h - 1
        end
        CH1[i][j], A1[i][j] = obj.getpixel(u, v, "col")
    end
end

local CH2 = {}
local A2 = {}
for i = 1, nx2 do
    CH2[i] = {}
    A2[i] = {}
    for j = 1, ny2 do
        local u = dw * (K1 - i) + w2
        local v = dh * (K2 - j) + h2
        if u < 0 then
            u = 0
        end
        if u > w - 1 then
            u = w - 1
        end
        if v < 0 then
            v = 0
        end
        if v > h - 1 then
            v = h - 1
        end
        CH2[i][j], A2[i][j] = obj.getpixel(u, v, "col")
    end
end

obj.setoption("drawtarget", "tempbuffer", R, R)
nR = R * math.sqrt(3) * 0.5
obj.load("figure", "四角形", 0xffffff, 2 * R)
effect("斜めクリッピング", "中心Y", -R, "角度", 150)
effect("斜めクリッピング", "中心Y", -R, "角度", -150)
effect("斜めクリッピング", "中心Y", R, "角度", 30)
effect("斜めクリッピング", "中心Y", R, "角度", -30)
effect("斜めクリッピング", "中心X", -nR, "角度", 90)
effect("斜めクリッピング", "中心X", nR, "角度", -90)
draw(0, 0, 0, 0.5)
obj.copybuffer("obj", "tmp")

if backC == 1 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.setoption("blend", "alpha_add")
else
    obj.copybuffer("tmp", "cache:back")
end

if totsu1 * totsu2 == 0 or totsuC == 0 then
    for i = -nx1, nx1 do
        for j = -ny1, ny1 do
            local x = dw * i
            local y = dh * j
            effect("単色化", "color", CH1[i][j], "輝度を保持する", 0)
            draw(x, y, 0, 1, A1[i][j])
        end
    end
    for i = 1, nx2 do
        for j = 1, ny2 do
            local x = dw * (K1 - i)
            local y = dh * (K2 - j)
            effect("単色化", "color", CH2[i][j], "輝度を保持する", 0)
            draw(x, y, 0, 1, A2[i][j])
        end
    end
else
    for i = -nx1, nx1 do
        for j = -ny1, ny1 do
            local x = dw * i
            local y = dh * j
            effect("単色化", "color", CH1[i][j], "輝度を保持する", 0)
            effect("凸エッジ", "幅", totsu1, "高さ", totsu2, "角度", totsu3)
            draw(x, y, 0, 1, A1[i][j])
        end
    end

    for i = 1, nx2 do
        for j = 1, ny2 do
            local x = dw * (K1 - i)
            local y = dh * (K2 - j)
            effect("単色化", "color", CH2[i][j], "輝度を保持する", 0)
            effect("凸エッジ", "幅", totsu1, "高さ", totsu2, "角度", totsu3)
            draw(x, y, 0, 1, A2[i][j])
        end
    end
end

obj.load("tempbuffer")
obj.setoption("blend", 0)

if ROT ~= 0 then
    obj.setoption("drawtarget", "tempbuffer", w0, h0)
    draw(0, 0, 0, 1, 1, 0, 0, ROT)
    obj.load("tempbuffer")
end
