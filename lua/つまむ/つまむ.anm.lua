--label:${ROOT_CATEGORY}\変形
---$track:ツマミ量％
---min=-1000
---max=1000
---step=0.1
local track_pinch_amount_percent = 100

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

---$track:分割量
---min=2
---max=200
---step=1
local track_division_count = 30

---$track:中心X
---min=-10000
---max=10000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-10000
---max=10000
---step=0.1
local track_center_y = 0

--trackgroup@track_center_x,track_center_y:中心

local width, height = obj.getpixel()
local maximum_displacement = height * track_pinch_amount_percent * 0.01
local radius_ratio = track_radius_percent * 0.01
local horizontal_ratio = track_horizontal_ratio_percent * 0.01

track_division_count = math.max(2, track_division_count)
local half_division_count = track_division_count * 0.5

obj.setanchor("track_center_x,track_center_y", 0)

local half_width = width * 0.5
local half_height = height * 0.5
obj.setoption("drawtarget", "tempbuffer", width, height)
obj.setoption("blend", "alpha_add")

local normalized_y_scale = 1 / (half_height * radius_ratio)
local normalized_x_scale = normalized_y_scale / horizontal_ratio

local z_displacements = {}
for i = 0, track_division_count do
    z_displacements[i] = {}
    local x = half_width * (i - half_division_count) / half_division_count
    for j = 0, track_division_count do
        local y = half_height * (j - half_division_count) / half_division_count
        local normalized_x = (x - track_center_x) * normalized_x_scale
        local normalized_y = (y - track_center_y) * normalized_y_scale
        local normalized_radius = math.sqrt(normalized_x * normalized_x + normalized_y * normalized_y)
        z_displacements[i][j] = 0
        if normalized_radius <= 1 then
            z_displacements[i][j] = z_displacements[i][j]
                + maximum_displacement * (normalized_radius * normalized_radius - 1) ^ 2
        end
    end
end
local u0 = 0
local vertices = {}
for i = 0, track_division_count - 1 do
    local u1 = width * (i + 1) / track_division_count
    local x0 = u0 - half_width
    local x1 = u1 - half_width
    local v0 = 0
    for j = 0, track_division_count - 1 do
        local v1 = height * (j + 1) / track_division_count
        local y0 = v0 - half_height
        local y1 = v1 - half_height
        vertices[#vertices + 1] = {
            x0,
            y0,
            z_displacements[i][j],
            x1,
            y0,
            z_displacements[i + 1][j],
            x1,
            y1,
            z_displacements[i + 1][j + 1],
            x0,
            y1,
            z_displacements[i][j + 1],
            u0,
            v0,
            u1,
            v0,
            u1,
            v1,
            u0,
            v1,
        }
        v0 = v1
    end
    u0 = u1
end
if #vertices > 0 then
    obj.drawpoly(vertices)
end

obj.load("tempbuffer")
