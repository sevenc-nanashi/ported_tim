--label:${ROOT_CATEGORY}\加工
local block_size, border_width, inner_size, half_inner_size, cell_count, horizontal_cell_radius, vertical_cell_radius, cell_min_x, cell_max_x, cell_min_y, cell_max_y, source_min_x, source_max_x, source_min_y, source_max_y, draw_min_x, draw_max_x, draw_min_y, draw_max_y, texture_min_x, texture_max_x, texture_min_y, texture_max_y
---$track:サイズ
---min=50
---max=1000
---step=0.1
local track_size = 100

---$track:幅
---min=0
---max=100
---step=0.1
local track_width = 10

---$track:高さ
---min=0
---max=3
---step=0.1
local track_height = 1.5

---$track:角度
---min=-360
---max=360
---step=0.1
local track_angle = -45

---$track:エンボス透明度
---min=0
---max=100
---step=0.01
local track_emboss_opacity = 0

obj.setoption("antialias", 0)

block_size = track_size
if block_size < 50 then
    block_size = 50
end
border_width = track_width
inner_size = block_size - 2 * border_width
if inner_size < 0 then
    border_width = block_size / 2
end
half_inner_size = inner_size / 2
track_emboss_opacity = (100 - track_emboss_opacity) / 100

cell_count = math.floor(obj.w / block_size)
horizontal_cell_radius = math.floor((cell_count + 1) / 2)

cell_count = math.floor(obj.h / block_size)
vertical_cell_radius = math.floor((cell_count + 1) / 2)

for i = -horizontal_cell_radius, horizontal_cell_radius do
    for j = -vertical_cell_radius, vertical_cell_radius do
        cell_min_x = block_size * i - 0.5 * inner_size
        cell_max_x = block_size * i + 0.5 * inner_size
        cell_min_y = block_size * j - 0.5 * inner_size
        cell_max_y = block_size * j + 0.5 * inner_size

        source_min_x = cell_min_x + obj.w / 2
        source_max_x = cell_max_x + obj.w / 2
        source_min_y = cell_min_y + obj.h / 2
        source_max_y = cell_max_y + obj.h / 2

        -- 中心
        draw_min_x = cell_min_x
        draw_max_x = cell_max_x
        draw_min_y = cell_min_y
        draw_max_y = cell_max_y
        texture_min_x = source_min_x
        texture_max_x = source_max_x
        texture_min_y = source_min_y
        texture_max_y = source_max_y
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )

        -- 上
        draw_min_x = cell_min_x
        draw_max_x = cell_max_x
        draw_min_y = cell_min_y - border_width
        draw_max_y = cell_min_y
        texture_min_x = source_min_x
        texture_max_x = source_max_x
        texture_min_y = source_min_y - inner_size / 2
        texture_max_y = source_min_y
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )

        -- 下
        draw_min_x = cell_min_x
        draw_max_x = cell_max_x
        draw_min_y = cell_max_y
        draw_max_y = cell_max_y + border_width
        texture_min_x = source_min_x
        texture_max_x = source_max_x
        texture_min_y = source_max_y
        texture_max_y = source_max_y + inner_size / 2
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )

        -- 左
        draw_min_x = cell_min_x - border_width
        draw_max_x = cell_min_x
        draw_min_y = cell_min_y
        draw_max_y = cell_max_y
        texture_min_x = source_min_x - inner_size / 2
        texture_max_x = source_min_x
        texture_min_y = source_min_y
        texture_max_y = source_max_y
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )

        -- 右
        draw_min_x = cell_max_x
        draw_max_x = cell_max_x + border_width
        draw_min_y = cell_min_y
        draw_max_y = cell_max_y
        texture_min_x = source_max_x
        texture_max_x = source_max_x + inner_size / 2
        texture_min_y = source_min_y
        texture_max_y = source_max_y
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )

        -- 左上
        draw_min_x = cell_min_x - border_width
        draw_max_x = cell_min_x
        draw_min_y = cell_min_y - border_width
        draw_max_y = cell_min_y
        texture_min_x = source_min_x - inner_size / 2
        texture_max_x = source_min_x
        texture_min_y = source_min_y - inner_size / 2
        texture_max_y = source_min_y
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )

        -- 右上
        draw_min_x = cell_max_x
        draw_max_x = cell_max_x + border_width
        draw_min_y = cell_min_y - border_width
        draw_max_y = cell_min_y
        texture_min_x = source_max_x
        texture_max_x = source_max_x + inner_size / 2
        texture_min_y = source_min_y - inner_size / 2
        texture_max_y = source_min_y
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )

        -- 左下
        draw_min_x = cell_min_x - border_width
        draw_max_x = cell_min_x
        draw_min_y = cell_max_y
        draw_max_y = cell_max_y + border_width
        texture_min_x = source_min_x - inner_size / 2
        texture_max_x = source_min_x
        texture_min_y = source_max_y
        texture_max_y = source_max_y + inner_size / 2
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )

        -- 右下
        draw_min_x = cell_max_x
        draw_max_x = cell_max_x + border_width
        draw_min_y = cell_max_y
        draw_max_y = cell_max_y + border_width
        texture_min_x = source_max_x
        texture_max_x = source_max_x + inner_size / 2
        texture_min_y = source_max_y
        texture_max_y = source_max_y + inner_size / 2
        obj.drawpoly(
            draw_min_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_min_y,
            0,
            draw_max_x,
            draw_max_y,
            0,
            draw_min_x,
            draw_max_y,
            0,
            texture_min_x,
            texture_min_y,
            texture_max_x,
            texture_min_y,
            texture_max_x,
            texture_max_y,
            texture_min_x,
            texture_max_y
        )
    end
end

obj.load("figure", "四角形", 0xffffff, block_size)
obj.setoption("blend", 3)
obj.effect("凸エッジ", "幅", border_width, "高さ", track_height, "角度", track_angle)
obj.effect("画像ループ", "横回数", 2 * horizontal_cell_radius + 1, "縦回数", 2 * vertical_cell_radius + 1)
obj.alpha = track_emboss_opacity
obj.draw()

obj.load("figure", "四角形", 0x0, block_size)
obj.setoption("blend", 1)
obj.effect("凸エッジ", "幅", border_width, "高さ", track_height, "角度", track_angle)
obj.effect("画像ループ", "横回数", 2 * horizontal_cell_radius + 1, "縦回数", 2 * vertical_cell_radius + 1)
obj.alpha = track_emboss_opacity
obj.draw()
