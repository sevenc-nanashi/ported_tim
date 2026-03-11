--label:tim2\シーンチェンジ\@シーンチェンジセットT.scn
---$track:サイズ
---min=10
---max=2000
---step=0.1
local rename_me_track0 = 100

---$track:開時間％
---min=0.1
---max=100
---step=0.1
local rename_me_track1 = 10

---$value:ランダム性％
local rdp = 100

---$value:乱数シード
local seed = 5

local T = obj.getvalue("scenechange")
local sz = rename_me_track0
local opt = rename_me_track1 * 0.01
local clt = 1 - opt
local w = obj.w
local h = obj.h
local w2 = w * 0.5
local h2 = h * 0.5
local nx = math.ceil(w / sz)
local ny = math.ceil(h / sz)
local szh = sz
local szb = 2 * sz
rdp = rdp * 0.01
if rdp < 0 then
    rdp = 1
elseif rdp > 1 then
    rdp = 1
end
local x = {}
local y = {}

for i = 0, nx do
    x[i] = {}
    y[i] = {}
    local ix = i * sz
    for j = 0, ny do
        x[i][j] = ix + obj.rand(-sz, sz, i, j + seed + 1000) * rdp
        y[i][j] = j * sz + obj.rand(-sz, sz, i, j + seed + 2000) * rdp
    end
end

for i = 0, nx do
    y[i][0] = 0
    y[i][ny] = h
end

for j = 0, ny do
    x[0][j] = 0
    x[nx][j] = w
end

local stt = {}
local sttmax = 0
local sttmin = 1000
for i = 0, nx - 1 do
    stt[i] = {}
    for j = 0, ny - 1 do
        stt[i][j] = obj.rand(0, 1000, i, j + seed + 3000)
        if sttmax < stt[i][j] then
            sttmax = stt[i][j]
        end
        if sttmin > stt[i][j] then
            sttmin = stt[i][j]
        end
    end
end

clt = clt / (sttmax - sttmin)
for i = 0, nx - 1 do
    for j = 0, ny - 1 do
        stt[i][j] = clt * (stt[i][j] - sttmin)
    end
end

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", "alpha_sub")

obj.load("figure", "円", 0xffffff, szb)
for i = 0, nx - 1 do
    for j = 0, ny - 1 do
        local dt = (T - stt[i][j]) / opt
        if dt > 1 then
            dt = 1
        end
        if dt > 0 then
            local cx = (x[i][j] + x[i + 1][j] + x[i + 1][j + 1] + x[i][j + 1]) * 0.25
            local cy = (y[i][j] + y[i + 1][j] + y[i + 1][j + 1] + y[i][j + 1]) * 0.25
            local d1 = (x[i][j] - cx) * (x[i][j] - cx) + (y[i][j] - cy) * (y[i][j] - cy)
            local d2 = (x[i + 1][j] - cx) * (x[i + 1][j] - cx) + (y[i + 1][j] - cy) * (y[i + 1][j] - cy)
            local d3 = (x[i + 1][j + 1] - cx) * (x[i + 1][j + 1] - cx) + (y[i + 1][j + 1] - cy) * (y[i + 1][j + 1] - cy)
            local d4 = (x[i][j + 1] - cx) * (x[i][j + 1] - cx) + (y[i][j + 1] - cy) * (y[i][j + 1] - cy)
            d1 = 2 * math.sqrt(math.max(d1, d2, d3, d4))
            obj.draw(cx - w2, cy - h2, 0, d1 / szb * dt)
        end
    end
end

obj.copybuffer("obj", "tmp")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
