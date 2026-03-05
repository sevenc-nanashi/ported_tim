--label:tim2
---$track:ﾂﾏﾐ量％
---min=-1000
---max=1000
---step=0.1
local track_percent = 100

---$track:半径％
---min=0
---max=1000
---step=0.1
local track_radius_percent = 100

---$track:横比％
---min=0
---max=1000
---step=0.1
local track_horizontal_ratio_percent = 100

---$value:分割量
local N = 30

---$value:中心
local Cpos = { 0, 0 }

local w, h = obj.getpixel()
local A = h * track_percent * 0.01
local hr = track_radius_percent * 0.01
local hw = track_horizontal_ratio_percent * 0.01

N = math.max(2, N)
local Nh = N * 0.5

obj.setanchor("Cpos", 1)

local w2 = w * 0.5
local h2 = h * 0.5
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.setoption("blend", "alpha_add")

local hy = 1 / (h2 * hr)
local hx = hy / hw

local TPz = {}
for i = 0, N do
    TPz[i] = {}
    local x = w2 * (i - Nh) / Nh
    for j = 0, N do
        local y = h2 * (j - Nh) / Nh
        local dx = (x - Cpos[1]) * hx
        local dy = (y - Cpos[2]) * hy
        local dr = math.sqrt(dx * dx + dy * dy)
        TPz[i][j] = 0
        if dr <= 1 then
            TPz[i][j] = TPz[i][j] + A * (dr * dr - 1) ^ 2
        end
    end
end
local u0 = 0
for i = 0, N - 1 do
    local u1 = w * (i + 1) / N
    local x0 = u0 - w2
    local x1 = u1 - w2
    local v0 = 0
    for j = 0, N - 1 do
        local v1 = h * (j + 1) / N
        local y0 = v0 - h2
        local y1 = v1 - h2
        obj.drawpoly(
            x0,
            y0,
            TPz[i][j],
            x1,
            y0,
            TPz[i + 1][j],
            x1,
            y1,
            TPz[i + 1][j + 1],
            x0,
            y1,
            TPz[i][j + 1],
            u0,
            v0,
            u1,
            v0,
            u1,
            v1,
            u0,
            v1
        )
        v0 = v1
    end
    u0 = u1
end

obj.load("tempbuffer")
