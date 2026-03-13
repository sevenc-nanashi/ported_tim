--label:tim2\シーンチェンジ\@シーンチェンジセットT
---$track:サイズ
---min=10
---max=2000
---step=0.1
local track_size = 100

---$track:開時間％
---min=0.1
---max=100
---step=0.1
local track_open_duration_percent = 10

---$track:ランダム性％
---min=0
---max=100
---step=0.1
local track_randomness_percent = 100

---$track:乱数シード
---min=0
---max=100000
---step=1
local track_random_seed = 5

local T = obj.getvalue("scenechange")
local sz = track_size
local opt = track_open_duration_percent * 0.01
local clt = 1 - opt
local w = obj.w
local h = obj.h
local w2 = w * 0.5
local h2 = h * 0.5
local nx = math.ceil(w / sz)
local ny = math.ceil(h / sz)
local szh = sz
local szb = 2 * sz
local random_offset_rate = track_randomness_percent * 0.01
local random_seed = math.floor(track_random_seed)
if random_offset_rate < 0 then
    random_offset_rate = 0
elseif random_offset_rate > 1 then
    random_offset_rate = 1
end
local x = {}
local y = {}

for i = 0, nx do
    x[i] = {}
    y[i] = {}
    local ix = i * sz
    for j = 0, ny do
        x[i][j] = ix + obj.rand(-sz, sz, i, j + random_seed + 1000) * random_offset_rate
        y[i][j] = j * sz + obj.rand(-sz, sz, i, j + random_seed + 2000) * random_offset_rate
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
        stt[i][j] = obj.rand(0, 1000, i, j + random_seed + 3000)
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

obj.copybuffer("cache:original", "object")
obj.setoption("drawtarget", "tempbuffer", obj.getpixel())

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

obj.copybuffer("cache:delete_area", "tempbuffer")
obj.copybuffer("tempbuffer", "cache:original")
obj.setoption("blend", "alpha_sub")
obj.copybuffer("object", "cache:delete_area")
obj.draw()
obj.copybuffer("object", "tempbuffer")
obj.setoption("drawtarget", "framebuffer")
obj.setoption("blend", "none")
obj.draw()
