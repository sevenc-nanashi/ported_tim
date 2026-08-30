--label:${ROOT_CATEGORY}\変形\@ワイヤー3D
---$track:横サイズ
---min=0
---max=10000
---step=0.1
local track_horizontal_size = 500

---$track:縦サイズ
---min=0
---max=10000
---step=0.1
local track_vertical_size = 500

---$track:高さ
---min=-5000
---max=5000
---step=0.1
local track_height = 150

---$track:高さ基準
---min=0
---max=100
---step=0.01
local track_height_base = 0

---$color:線色
local color = 0xffffff

---$check:塗り
local check_fill = 0

---$color:塗色
local fill_color = 0x0000ff

---$check:アンチエイリアス
local check_antialias = 1

---$check:高精度(線のみ)
local check_high_precision = 0

---$track:高精度間隔
---min=0.5
---max=200
---step=0.1
local high_precision_spacing = 2

---$figure:高精度形状
local high_precision_shape = "円"

---$check:高精度自動向き
local check_auto_direction = 1

---$track:単体横分割数
---min=1
---max=100
---step=1
local fallback_horizontal_split_count = 10

---$track:単体縦分割数
---min=1
---max=100
---step=1
local fallback_vertical_split_count = 10

---$track:単体ライン幅
---min=1
---max=1000
---step=0.1
local fallback_line_width = 2

---$check:YZ反転
local check_flip_yz = false

--hide@check_fill:check_high_precision==1
--hide@fill_color:check_fill==0
--hide@fill_color:check_high_precision==1
--hide@high_precision_spacing:check_high_precision==0
--hide@high_precision_shape:check_high_precision==0
--hide@check_auto_direction:check_high_precision==0

if T_WIRE_HORIZONTAL_SPLIT_COUNT == nil then
    T_WIRE_HORIZONTAL_SPLIT_COUNT = math.floor(fallback_horizontal_split_count or 10)
    T_WIRE_VERTICAL_SPLIT_COUNT = math.floor(fallback_vertical_split_count or 10)
    T_WIRE_LINE_WIDTH = fallback_line_width or 2
    local w, h = obj.getpixel()
    obj.pixeloption("type", "yc")
    obj.pixeloption("get", "obj")
    T_WIRE_DATA = {}
    for i = 0, T_WIRE_HORIZONTAL_SPLIT_COUNT do
        T_WIRE_DATA[i] = {}
        for j = 0, T_WIRE_VERTICAL_SPLIT_COUNT do
            local yi, cbi, cri, ai = obj.getpixel(
                (w - 1) * i / T_WIRE_HORIZONTAL_SPLIT_COUNT,
                (h - 1) * j / T_WIRE_VERTICAL_SPLIT_COUNT,
                "yc"
            )
            T_WIRE_DATA[i][j] = yi / 4096
        end
    end
end

local width = track_horizontal_size
local depth = track_vertical_size
local height = -track_height
local height_base_ratio = track_height_base * 0.01

local horizontal_split_count = T_WIRE_HORIZONTAL_SPLIT_COUNT
local vertical_split_count = T_WIRE_VERTICAL_SPLIT_COUNT
local line_width = T_WIRE_LINE_WIDTH
local data = T_WIRE_DATA

local ox, oy, oz = obj.ox, obj.oy, obj.oz
ox = ox - width * 0.5
oz = oz + depth * 0.5
local cell_width = width / horizontal_split_count
local cell_depth = depth / vertical_split_count
local half_cell_width = cell_width * 0.5
local half_cell_depth = cell_depth * 0.5

high_precision_spacing = high_precision_spacing or 2
if high_precision_spacing < 0.5 then
    high_precision_spacing = 0.5
end

for i = 0, horizontal_split_count do
    for j = 0, vertical_split_count do
        data[i][j] = height * (data[i][j] - height_base_ratio) + oy
    end
end

obj.setoption("antialias", check_antialias)
obj.setoption("focus_mode", "fixed_size")

if check_high_precision == 0 then
    local o_drawpoly

    if check_fill == 0 then
        obj.load("figure", "四角形", color, math.max(cell_width, cell_depth), line_width)
        if check_flip_yz then
            o_drawpoly = function(cx, x0, x1, y0, y1, y2, y3, cz, half_cell_depth)
                local z0 = cz + half_cell_depth
                local z1 = cz - half_cell_depth
                obj.drawpoly(x0, y0, z0, x1, y1, z0, x1, y2, z1, x0, y3, z1)
            end
        else
            o_drawpoly = function(cx, x0, x1, y0, y1, y2, y3, cz, half_cell_depth)
                local z0 = cz + half_cell_depth
                local z1 = cz - half_cell_depth
                obj.drawpoly(x0, -z0, y0, x1, -z0, y1, x1, -z1, y2, x0, -z1, y3)
            end
        end
    else
        local fs = math.max(cell_width, cell_depth)
        obj.load("figure", "四角形", fill_color, fs)
        obj.copybuffer("tempbuffer", "object")
        obj.setoption("drawtarget", "tempbuffer")
        obj.load("figure", "四角形", color, fs, line_width)
        obj.draw()
        obj.load("tempbuffer")
        obj.setoption("drawtarget", "framebuffer")

        if check_flip_yz then
            o_drawpoly = function(cx, x0, x1, y0, y1, y2, y3, cz, half_cell_depth)
                local cy = (y0 + y1 + y2 + y3) * 0.25
                local z0 = cz + half_cell_depth
                local z1 = cz - half_cell_depth
                local w, w2, h2 = obj.w, obj.w * 0.5, obj.h * 0.5
                obj.drawpoly(cx, cy, cz, cx, cy, cz, x0, y0, z0, x1, y1, z0, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cy, cz, cx, cy, cz, x1, y1, z0, x1, y2, z1, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cy, cz, cx, cy, cz, x1, y2, z1, x0, y3, z1, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cy, cz, cx, cy, cz, x0, y3, z1, x0, y0, z0, w2, h2, w2, h2, 0, 0, w, 0)
            end
        else
            o_drawpoly = function(cx, x0, x1, y0, y1, y2, y3, cz, half_cell_depth)
                local cy = (y0 + y1 + y2 + y3) * 0.25
                cz = -cz
                local z0 = cz - half_cell_depth
                local z1 = cz + half_cell_depth
                local w, w2, h2 = obj.w, obj.w * 0.5, obj.h * 0.5
                obj.drawpoly(cx, cz, cy, cx, cz, cy, x0, z0, y0, x1, z0, y1, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cz, cy, cx, cz, cy, x1, z0, y1, x1, z1, y2, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cz, cy, cx, cz, cy, x1, z1, y2, x0, z1, y3, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cz, cy, cx, cz, cy, x0, z1, y3, x0, z0, y0, w2, h2, w2, h2, 0, 0, w, 0)
            end
        end
    end

    for i = 0, horizontal_split_count - 1 do
        local x = ox + cell_width * (0.5 + i)
        local x0, x1 = x - half_cell_width, x + half_cell_width
        for j = 0, vertical_split_count - 1 do
            local z = oz - cell_depth * (0.5 + j)
            local y0, y1, y2, y3 = data[i][j], data[i + 1][j], data[i + 1][j + 1], data[i][j + 1]

            o_drawpoly(x, x0, x1, y0, y1, y2, y3, z, half_cell_depth)
        end
    end
else
    local set_cx, set_cz
    if check_flip_yz then
        set_cx = function(x, y0, y1, z0, dz, high_precision_spacing)
            local dy = y1 - y0
            local r = math.sqrt(dy * dy + dz * dz)
            local n = math.floor(r / high_precision_spacing)
            for i = 1, n - 1 do
                local rt = i / n
                obj.draw(x, y0 + dy * rt, z0 + dz * rt)
            end
        end
        set_cz = function(x0, dx, y0, y1, z, high_precision_spacing)
            local dy = y1 - y0
            local r = math.sqrt(dx * dx + dy * dy)
            local n = math.floor(r / high_precision_spacing)
            for i = 1, n - 1 do
                local rt = i / n
                obj.draw(x0 + dx * rt, y0 + dy * rt, z)
            end
        end
    else
        set_cx = function(x, y0, y1, z0, dz, high_precision_spacing)
            local dy = y1 - y0
            local r = math.sqrt(dy * dy + dz * dz)
            local n = math.floor(r / high_precision_spacing)
            for i = 1, n - 1 do
                local rt = i / n
                obj.draw(x, -z0 - dz * rt, y0 + dy * rt)
            end
        end
        set_cz = function(x0, dx, y0, y1, z, high_precision_spacing)
            local dy = y1 - y0
            local r = math.sqrt(dx * dx + dy * dy)
            local n = math.floor(r / high_precision_spacing)
            for i = 1, n - 1 do
                local rt = i / n
                obj.draw(x0 + dx * rt, -z, y0 + dy * rt)
            end
        end
    end

    obj.load("figure", high_precision_shape, color, line_width * 2)
    if check_auto_direction == 1 then
        obj.setoption("billboard", 3)
    end

    local x = {}
    local z = {}
    for i = 0, horizontal_split_count do
        x[i] = ox + cell_width * i
    end
    for j = 0, vertical_split_count do
        z[j] = oz - cell_depth * j
    end

    for i = 0, horizontal_split_count - 1 do
        for j = 0, vertical_split_count do
            set_cz(x[i], cell_width, data[i][j], data[i + 1][j], z[j], high_precision_spacing)
        end
    end

    for i = 0, horizontal_split_count do
        for j = 0, vertical_split_count - 1 do
            set_cx(x[i], data[i][j], data[i][j + 1], z[j], -cell_depth, high_precision_spacing)
        end
    end

    if check_flip_yz then
        for i = 0, horizontal_split_count do
            for j = 0, vertical_split_count do
                obj.draw(x[i], data[i][j], z[j])
            end
        end
    else
        for i = 0, horizontal_split_count do
            for j = 0, vertical_split_count do
                obj.draw(x[i], -z[j], data[i][j])
            end
        end
    end
end

T_WIRE_HORIZONTAL_SPLIT_COUNT = nil
T_WIRE_VERTICAL_SPLIT_COUNT = nil
T_WIRE_LINE_WIDTH = nil
T_WIRE_DATA = nil
