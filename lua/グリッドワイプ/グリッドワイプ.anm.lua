--label:${ROOT_CATEGORY}\切り替え効果
---$track:展開
---min=0
---max=100
---step=0.1
local track_unfold = 25

---$track:サイズ
---min=5
---max=5000
---step=0.1
local track_size = 50

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 45

---$track:縦横比[%]
---min=1
---max=100
---step=0.1
local track_aspect_ratio_percent = 5

---$select:ワイプタイプ
---扉=0
---放射(十字)=1
---矩形(十字)=2
---十字線=3
---菱形(十字)=4
---放射=5
---矩形=6
---直線=7
---菱形=8
local select_wipe_type = 0

---$check:反転
local check_reverse = 0

---$track:中心座標X
---min=-10000
---max=10000
---step=0.1
local track_center_position_x = 0

---$track:中心座標Y
---min=-10000
---max=10000
---step=0.1
local track_center_position_y = 0

--trackgroup@track_center_position_x,track_center_position_y:中心座標

local wipe_door = function(
    progress,
    cell_size,
    rotation,
    aspect_ratio,
    cell_count,
    total_length,
    half_length,
    cos,
    sin,
    center_x,
    center_y
)
    local t = (total_length + cell_size / aspect_ratio) * progress
    local p = t * aspect_ratio
    obj.setoption(
        "drawtarget",
        "tempbuffer",
        math.max(math.min(t, total_length), 6),
        math.max(math.min(p, total_length), 6)
    )
    obj.load("figure", "四角形", 0xffffff, math.max(t, p, 6))
    obj.drawpoly(-t / 2, 0, 0, 0, -p / 2, 0, t / 2, 0, 0, 0, p / 2, 0)
    obj.copybuffer("object", "tempbuffer")
    obj.copybuffer("tempbuffer", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    local deg = track_rotation + 90
    for i = -cell_count, cell_count do
        local x = i * cell_size
        local y = x * sin
        x = x * cos
        obj.draw(x + center_x, y + center_y, 0, 1, 1, 0, 0, deg)
    end
    obj.load("figure", "四角形", 0xffffff, total_length)
    for i = -cell_count, cell_count do
        local ai = math.abs(i)
        local u = ai * cell_size
        local v = p * (1 - 2 / t * u) * 0.5
        if v > 0 then
            local dy = i * cell_size
            local dx = -dy * sin + center_x
            dy = dy * cos + center_y
            local ar1x = half_length * cos
            local ar1y = half_length * sin
            local ar2x = -v * sin
            local ar2y = v * cos
            local x0, y0 = dx - ar1x - ar2x, dy - ar1y - ar2y
            local x1, y1 = dx + ar1x - ar2x, dy + ar1y - ar2y
            local x2, y2 = dx + ar1x + ar2x, dy + ar1y + ar2y
            local x3, y3 = dx - ar1x + ar2x, dy - ar1y + ar2y
            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
        end
    end
end

local wipe_radial = function(
    progress,
    cell_size,
    rotation,
    aspect_ratio,
    cell_count,
    total_length,
    half_length,
    cos,
    sin,
    center_x,
    center_y,
    repeat_count
)
    obj.setoption("drawtarget", "tempbuffer", total_length, total_length * aspect_ratio)

    obj.load("figure", "四角形", 0xffffff, total_length / 30)
    obj.setoption("blend", "alpha_add")
    for i = -30, 29 do
        local x1 = half_length * i / 30
        local x2 = half_length * (i + 1) / 30
        local y1 = aspect_ratio * (2 / total_length * x1 * x1 - half_length)
        local y2 = aspect_ratio * (2 / total_length * x2 * x2 - half_length)
        obj.drawpoly(x1, y1, 0, x2, y2, 0, x2, -y2, 0, x1, -y1, 0)
    end

    obj.copybuffer("object", "tempbuffer")
    obj.copybuffer("tempbuffer", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    local dd = cell_size * cell_size + 4 * aspect_ratio * aspect_ratio * total_length * total_length
    local rmax = progress * math.sqrt((dd + cell_size * math.sqrt(dd)) / (8 * aspect_ratio * aspect_ratio))
    for i = -cell_count, cell_count do
        local y0 = i * cell_size
        local rw = rmax * rmax - y0 * y0
        if rw > 0 then
            rw = math.sqrt(rw)
            local zoom = 2 * rw / total_length
            local x0 = -y0 * sin
            y0 = y0 * cos
            obj.draw(x0 + center_x, y0 + center_y, 0, zoom, 1, 0, 0, track_rotation)
            if repeat_count == 2 then
                obj.draw(y0 + center_x, -x0 + center_y, 0, zoom, 1, 0, 0, track_rotation + 90)
            end
        end
    end
end

local wipe_rectangular = function(
    progress,
    cell_size,
    rotation,
    aspect_ratio,
    cell_count,
    total_length,
    half_length,
    cos,
    sin,
    center_x,
    center_y,
    repeat_count
)
    local rotdraw = function(x0, y0, x1, y1, x2, y2, x3, y3, cos, sin, center_x, center_y)
        x0, y0 = x0 * cos - y0 * sin + center_x, x0 * sin + y0 * cos + center_y
        x1, y1 = x1 * cos - y1 * sin + center_x, x1 * sin + y1 * cos + center_y
        x2, y2 = x2 * cos - y2 * sin + center_x, x2 * sin + y2 * cos + center_y
        x3, y3 = x3 * cos - y3 * sin + center_x, x3 * sin + y3 * cos + center_y
        obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
    end
    local t = (total_length + cell_size / aspect_ratio) * progress * 0.5
    local p = t * aspect_ratio
    obj.copybuffer("tempbuffer", "cache:ori")
    obj.setoption("drawtarget", "tempbuffer")
    obj.load("figure", "四角形", 0xffffff, total_length * 0.5)
    obj.effect("リサイズ", "Y", track_aspect_ratio_percent)
    obj.setoption("blend", "alpha_sub")
    for i = -cell_count, cell_count do
        local y0 = i * cell_size
        local y_a = math.abs(y0)
        local p1 = p * (1 - y_a / t)
        if p1 > 0 then
            rotdraw(-t, y0, -t, y0, -y_a, -p1 + y0, -y_a, p1 + y0, cos, sin, center_x, center_y)
            rotdraw(t, y0, t, y0, y_a, p1 + y0, y_a, -p1 + y0, cos, sin, center_x, center_y)
            rotdraw(-y_a, -p1 + y0, y_a, -p1 + y0, y_a, p1 + y0, -y_a, p1 + y0, cos, sin, center_x, center_y)
            if repeat_count == 2 then
                rotdraw(-t, y0, -t, y0, -y_a, -p1 + y0, -y_a, p1 + y0, -sin, cos, center_x, center_y)
                rotdraw(t, y0, t, y0, y_a, p1 + y0, y_a, -p1 + y0, -sin, cos, center_x, center_y)
                rotdraw(-y_a, -p1 + y0, y_a, -p1 + y0, y_a, p1 + y0, -y_a, p1 + y0, -sin, cos, center_x, center_y)
            end
        end
    end
end

local wipe_crossline = function(
    progress,
    cell_size,
    rotation,
    aspect_ratio,
    cell_count,
    total_length,
    half_length,
    cos,
    sin,
    center_x,
    center_y,
    repeat_count
)
    local t = (total_length + cell_size / aspect_ratio) * progress
    local p = t * aspect_ratio
    local width, height = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", width, height)
    obj.copybuffer("tempbuffer", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    obj.load("figure", "四角形", 0xffffff, total_length)
    for j = 1, repeat_count do
        for i = -cell_count, cell_count do
            local ai = math.abs(i)
            local u = ai * cell_size
            local v = p * (1 - 2 / t * u) * 0.5
            if v > 0 then
                local dy = i * cell_size
                local dx = -dy * sin + center_x
                dy = dy * cos + center_y
                local ar1x = half_length * cos
                local ar1y = half_length * sin
                local ar2x = -v * sin
                local ar2y = v * cos
                local x0, y0 = dx - ar1x - ar2x, dy - ar1y - ar2y
                local x1, y1 = dx + ar1x - ar2x, dy + ar1y - ar2y
                local x2, y2 = dx + ar1x + ar2x, dy + ar1y + ar2y
                local x3, y3 = dx - ar1x + ar2x, dy - ar1y + ar2y
                obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
            end
        end
        cos, sin = -sin, cos
    end
end

local wipe_diamond = function(
    progress,
    cell_size,
    rotation,
    aspect_ratio,
    cell_count,
    total_length,
    half_length,
    cos,
    sin,
    center_x,
    center_y,
    repeat_count
)
    local t = (total_length + cell_size / aspect_ratio) * progress
    local p = t * aspect_ratio
    obj.setoption(
        "drawtarget",
        "tempbuffer",
        math.max(math.min(t, total_length), 6),
        math.max(math.min(p, total_length), 6)
    )
    obj.load("figure", "四角形", 0xffffff, math.max(t, p, 6))
    obj.drawpoly(-t / 2, 0, 0, 0, -p / 2, 0, t / 2, 0, 0, 0, p / 2, 0)
    obj.copybuffer("object", "tempbuffer")
    obj.copybuffer("tempbuffer", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    local deg = track_rotation
    for i = -cell_count, cell_count do
        local x = i * cell_size
        local y = x * cos
        x = -x * sin
        obj.draw(x + center_x, y + center_y, 0, 1, 1, 0, 0, deg)
        if repeat_count == 2 then
            obj.draw(-y + center_x, x + center_y, 0, 1, 1, 0, 0, deg + 90)
        end
    end
end

local progress = track_unfold * 0.01
local cell_size = track_size
local rotation = math.rad(track_rotation)
local aspect_ratio = track_aspect_ratio_percent * 0.01

local w, h = obj.getpixel()

obj.setanchor("track_center_position_x,track_center_position_y", 0)
w = w + 2 * math.abs(track_center_position_x)
h = h + 2 * math.abs(track_center_position_y)

local l0 = math.sqrt(w * w + h * h)

local n0 = 0.5 * l0 / cell_size
local cell_count = math.ceil(n0)
local half_length = n0 * cell_size
local total_length = 2 * half_length
local cos = math.cos(rotation)
local sin = math.sin(rotation)

obj.copybuffer("cache:ori", "object")

if select_wipe_type == 0 then
    wipe_door(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y
    )
elseif select_wipe_type == 1 then
    wipe_radial(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y,
        2
    )
elseif select_wipe_type == 2 then
    wipe_rectangular(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y,
        2
    )
elseif select_wipe_type == 3 then
    wipe_crossline(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y,
        2
    )
elseif select_wipe_type == 4 then
    wipe_diamond(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y,
        2
    )
elseif select_wipe_type == 5 then
    wipe_radial(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y,
        1
    )
elseif select_wipe_type == 6 then
    wipe_rectangular(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y,
        1
    )
elseif select_wipe_type == 7 then
    wipe_crossline(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y,
        1
    )
else
    wipe_diamond(
        progress,
        cell_size,
        rotation,
        aspect_ratio,
        cell_count,
        total_length,
        half_length,
        cos,
        sin,
        track_center_position_x,
        track_center_position_y,
        1
    )
end

obj.copybuffer("object", "tempbuffer")
obj.setoption("blend", 0)
if check_reverse == 1 then
    obj.effect("反転", "透明度反転", 1)
end
