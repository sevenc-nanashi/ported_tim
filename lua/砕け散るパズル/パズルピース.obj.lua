--label:${ROOT_CATEGORY}\カスタムオブジェクト
---$track:サイズ
---min=4
---max=1000
---step=1
local track_piece_size = 120

---$track:P形状
---min=1
---max=22
---step=1
local track_piece_shape = 1

---$track:凹凸
---min=1
---max=2
---step=1
local track_bump = 1

---$color_piece:色
local color_piece = 0xffffff

local piece_shape = track_piece_shape
local piece_size = math.floor(track_piece_size)

local draw_edge_shapes = function(half_piece_size, rotation_degrees, ...)
    local edge_flags = { ... }
    if edge_flags[1] == 1 then
        obj.draw(0, -half_piece_size, 0, 1, 1, 0, 0, rotation_degrees)
    end
    if edge_flags[2] == 1 then
        obj.draw(half_piece_size, 0, 0, 1, 1, 0, 0, 90 + rotation_degrees)
    end
    if edge_flags[3] == 1 then
        obj.draw(0, half_piece_size, 0, 1, 1, 0, 0, 180 + rotation_degrees)
    end
    if edge_flags[4] == 1 then
        obj.draw(-half_piece_size, 0, 0, 1, 1, 0, 0, 270 + rotation_degrees)
    end
end

local create_base_edge_set = function(piece_size, half_piece_size, ...)
    local edge_flags = { ... }
    obj.setoption("drawtarget", "tempbuffer", 2 * piece_size, 2 * piece_size)
    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "alpha_add")
    obj.drawpoly(
        -half_piece_size,
        -half_piece_size,
        0,
        half_piece_size,
        -half_piece_size,
        0,
        half_piece_size,
        half_piece_size,
        0,
        -half_piece_size,
        half_piece_size,
        0
    )

    obj.copybuffer("object", "cache:Img1")
    obj.setoption("blend", "alpha_add")
    draw_edge_shapes(half_piece_size, 0, edge_flags[1], edge_flags[2], edge_flags[3], edge_flags[4])
    obj.setoption("blend", "alpha_sub")
    draw_edge_shapes(half_piece_size, 180, edge_flags[5], edge_flags[6], edge_flags[7], edge_flags[8])
end

local create_combined_edge_set = function(piece_size, half_piece_size, ...)
    local edge_flags = { ... }
    create_base_edge_set(piece_size, half_piece_size, unpack(edge_flags, 1, 8))

    obj.copybuffer("object", "cache:Img2")
    obj.setoption("blend", "alpha_add")
    draw_edge_shapes(half_piece_size, 0, edge_flags[9], edge_flags[10], edge_flags[11], edge_flags[12])
    obj.setoption("blend", "alpha_sub")
    draw_edge_shapes(half_piece_size, 180, edge_flags[13], edge_flags[14], edge_flags[15], edge_flags[16])
end

local create_piece_shape = function(piece_size, half_piece_size, piece_shape)
    if piece_shape == 1 then
        create_combined_edge_set(piece_size, half_piece_size, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0)
    elseif piece_shape == 2 then
        create_combined_edge_set(piece_size, half_piece_size, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0)
    elseif piece_shape == 3 then
        create_combined_edge_set(piece_size, half_piece_size, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1)
    elseif piece_shape == 4 then
        create_combined_edge_set(piece_size, half_piece_size, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0)
    elseif piece_shape == 9 or piece_shape == 13 or piece_shape == 18 then
        create_base_edge_set(piece_size, half_piece_size, 1, 0, 1, 0, 0, 1, 0, 1)
    elseif piece_shape == 10 or piece_shape == 14 or piece_shape == 19 then
        create_base_edge_set(piece_size, half_piece_size, 1, 1, 0, 0, 0, 0, 1, 1)
    elseif piece_shape == 11 or piece_shape == 15 or piece_shape == 20 then
        create_base_edge_set(piece_size, half_piece_size, 1, 1, 1, 1, 0, 0, 0, 0)
    elseif piece_shape == 12 or piece_shape == 16 or piece_shape == 21 then
        create_base_edge_set(piece_size, half_piece_size, 1, 0, 0, 0, 0, 1, 1, 1)
    elseif piece_shape == 17 or piece_shape == 22 then
        create_base_edge_set(piece_size, half_piece_size, 1, 1, 1, 1, 1, 1, 1, 1)
    end
end

local half_piece_size = piece_size / 2
local quarter_piece_size = piece_size / 4
local piece_canvas_size = 2 * piece_size + piece_size % 2 -- 四隅に隙間ができることがあるのを防止
local aligned_half_piece_size = 2 * math.floor((half_piece_size + 1) / 2) -- 余分な線が入るのを防止

if piece_shape >= 1 and piece_shape <= 4 then
    obj.setoption("drawtarget", "tempbuffer", piece_size, piece_size)
    local antialias_scale = 2
    local scale_ratio = piece_size / 200
    obj.load("figure", "円", 0xffffff, 78 * scale_ratio * antialias_scale)
    obj.setoption("blend", "none")
    local x0 = -39 * scale_ratio
    local y0 = (-138 - 39 * 0.79 + 100) * scale_ratio
    local y2 = (-138 + 39 * 0.79 + 100 + 2) * scale_ratio
    obj.drawpoly(x0, y0, 0, -x0, y0, 0, -x0, y2, 0, x0, y2, 0)

    local curve_adjustment = (2857 - 21 * math.sqrt(18119)) / 4640

    local x4, y4 = 32.5445 * scale_ratio, (121.0223 + 0.4) * scale_ratio - 100 * scale_ratio
    local x5, y5 = 23.9438 * scale_ratio, 110.7341 * scale_ratio - 100 * scale_ratio
    local x6, y6 =
        (32 + curve_adjustment) * scale_ratio,
        (104 - math.sqrt(21 * 21 / 4 - curve_adjustment * curve_adjustment)) * scale_ratio - 100 * scale_ratio

    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "none")
    obj.drawpoly(-x4, -y4, 0, x4, -y4, 0, x5, -y5, 0, -x5, -y5, 0)
    obj.drawpoly(-x5, -y5, 0, x5, -y5, 0, x6, -y6, 0, -x6, -y6, 0)

    obj.drawpoly(-x6, -y6, 0, x6, -y6, 0, x6, piece_size / 2, 0, -x6, piece_size / 2, 0)

    obj.drawpoly(x6, -y6, 0, half_piece_size, 0, 0, half_piece_size, half_piece_size, 0, x6, half_piece_size, 0)
    obj.drawpoly(-x6, -y6, 0, -half_piece_size, 0, 0, -half_piece_size, half_piece_size, 0, -x6, half_piece_size, 0)

    obj.load("figure", "円", 0xffffff, 21 * scale_ratio * antialias_scale)
    obj.setoption("blend", "alpha_sub")
    obj.draw(32 * scale_ratio, -104 * scale_ratio + 100 * scale_ratio, 0, 1 / antialias_scale)
    obj.draw(-32 * scale_ratio, -104 * scale_ratio + 100 * scale_ratio, 0, 1 / antialias_scale)

    obj.copybuffer("cache:Img2", "tempbuffer")

    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "alpha_sub")
    obj.drawpoly(
        -half_piece_size,
        0,
        0,
        half_piece_size,
        0,
        0,
        half_piece_size,
        half_piece_size,
        0,
        -half_piece_size,
        half_piece_size,
        0
    )

    obj.copybuffer("cache:Img1", "tempbuffer")

    obj.copybuffer("tempbuffer", "cache:Img2")
    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "alpha_add")
    obj.drawpoly(
        -half_piece_size,
        0,
        0,
        half_piece_size,
        0,
        0,
        half_piece_size,
        -half_piece_size,
        0,
        -half_piece_size,
        -half_piece_size,
        0
    )

    obj.copybuffer("object", "tempbuffer")
    obj.effect("反転", "透明度反転", 1)
    obj.effect("ローテーション", "90度回転", 2)
    obj.copybuffer("cache:Img2", "object")

    create_piece_shape(piece_size, half_piece_size, piece_shape)
elseif piece_shape >= 5 and piece_shape <= 8 then
    local diagonal_size = math.sqrt(2) * piece_size + 1
    obj.setoption("drawtarget", "tempbuffer", piece_canvas_size, piece_canvas_size)
    obj.load("figure", "円", 0xffffff, 3 * diagonal_size)
    obj.setoption("blend", "alpha_add")
    obj.draw(0, 0, 0, 1 / 3)
    obj.copybuffer("object", "tempbuffer")
    obj.setoption("blend", "alpha_sub")
    if piece_shape == 5 then
        obj.draw(-piece_size - 1, 0, 0) --ゴミ対策で±1
        obj.draw(piece_size + 1, 0, 0)
    elseif piece_shape == 6 then
        obj.draw(0, piece_size + 1, 0)
        obj.draw(-piece_size - 1, 0, 0)
    elseif piece_shape == 8 then
        obj.draw(0, piece_size + 1, 0)
    end
elseif piece_shape >= 9 and piece_shape <= 22 then
    local x0, x1, x2, x3
    local y0, y1, y2, y3

    if piece_shape >= 9 and piece_shape <= 12 then
        x0, y0, x1, y1, x2, y2, x3, y3 =
            -half_piece_size * 0.44,
            -half_piece_size * 0.25,
            half_piece_size * 0.44,
            -half_piece_size * 0.25,
            half_piece_size * 0.3,
            0,
            -half_piece_size * 0.3,
            0
    elseif piece_shape >= 13 and piece_shape <= 17 then
        local notch_unit = piece_size / 5
        x0, y0, x1, y1, x2, y2, x3, y3 =
            -half_piece_size + notch_unit,
            -0.6 * notch_unit,
            -half_piece_size + 2 * notch_unit,
            -0.6 * notch_unit,
            -half_piece_size + 2 * notch_unit,
            0,
            -half_piece_size + notch_unit,
            0
    elseif piece_shape >= 18 and piece_shape <= 22 then
        local notch_unit = piece_size / 7
        x0, y0, x1, y1, x2, y2, x3, y3 =
            -half_piece_size + 2 * notch_unit,
            -1.2 * notch_unit,
            -half_piece_size + 2 * notch_unit,
            -1.2 * notch_unit,
            -half_piece_size + 3 * notch_unit,
            0,
            -half_piece_size + notch_unit,
            0
    end

    obj.setoption("drawtarget", "tempbuffer", piece_size, aligned_half_piece_size)
    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "alpha_add")
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)

    if (piece_shape >= 13 and piece_shape <= 16) or (piece_shape >= 18 and piece_shape <= 21) then
        obj.drawpoly(-x0, y0, 0, -x1, y1, 0, -x2, y2, 0, -x3, y3, 0)
    end

    obj.copybuffer("cache:Img1", "tempbuffer")
    create_piece_shape(piece_size, half_piece_size, piece_shape)
end

if
    track_bump == 2
    and piece_shape ~= 2
    and piece_shape ~= 6
    and piece_shape ~= 10
    and piece_shape ~= 14
    and piece_shape ~= 19
    and piece_shape ~= 17
    and piece_shape ~= 22
then
    obj.copybuffer("cache:PC1", "tempbuffer")
    obj.setoption("drawtarget", "tempbuffer", piece_canvas_size, piece_canvas_size)
    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "alpha_add")
    obj.drawpoly(
        -half_piece_size,
        -half_piece_size,
        0,
        half_piece_size,
        -half_piece_size,
        0,
        half_piece_size,
        half_piece_size,
        0,
        -half_piece_size,
        half_piece_size,
        0
    )
    obj.drawpoly(
        0,
        -piece_size,
        0,
        0,
        -piece_size,
        0,
        half_piece_size,
        -half_piece_size,
        0,
        -half_piece_size,
        -half_piece_size,
        0
    )
    obj.drawpoly(
        piece_size,
        0,
        0,
        piece_size,
        0,
        0,
        half_piece_size,
        half_piece_size,
        0,
        half_piece_size,
        -half_piece_size,
        0
    )
    obj.drawpoly(
        0,
        piece_size,
        0,
        0,
        piece_size,
        0,
        -half_piece_size,
        half_piece_size,
        0,
        half_piece_size,
        half_piece_size,
        0
    )
    obj.drawpoly(
        -piece_size,
        0,
        0,
        -piece_size,
        0,
        0,
        -half_piece_size,
        -half_piece_size,
        0,
        -half_piece_size,
        half_piece_size,
        0
    )
    obj.copybuffer("object", "cache:PC1")
    obj.setoption("blend", "alpha_sub")
    obj.draw(-piece_size, 0, 0)
    obj.draw(piece_size, 0, 0)
    obj.draw(0, -piece_size, 0)
    obj.draw(0, piece_size, 0)
end
obj.copybuffer("object", "tempbuffer")
obj.effect("単色化", "輝度を保持する", 0, "color", color_piece)
