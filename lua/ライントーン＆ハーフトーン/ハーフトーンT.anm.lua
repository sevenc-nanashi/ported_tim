--label:${ROOT_CATEGORY}\加工
---$track:サイズ
---min=5
---max=1000
---step=0.1
local track_size = 10

---$track:トーン小
---min=0
---max=500
---step=0.1
local track_tone_small = 0

---$track:トーン大
---min=0
---max=500
---step=0.1
local track_tone_large = 100

---$track:回転
---min=-3600
---max=3600
---step=0.1
---zero_label=
---scale=0.05
local track_rotation = 0

---$color:シャドウ色
local shadow_color = 0x0

---$color:ハイライト色
local highlight_color = 0xffffff

---$figure:トーン形状
local tone_figure = "円"

---$check:段違い
local check_staggered = true

---$check:背景色非表示
local check_hide_background_color = false

---$check:トーン反転
local check_invert_tone = false

---$check:自分自身で型抜き
local check_punch_out_self = true

obj.copybuffer("cache:ori_img", "object")
local horizontal_spacing = track_size
local minimum_tone_scale = track_tone_small * 0.01
local tone_scale_range = track_tone_large * 0.01 - minimum_tone_scale
local rotation_degrees = track_rotation
local image_width, image_height = obj.getpixel()
local vertical_spacing = horizontal_spacing
local figure_size = horizontal_spacing
if check_staggered then
    horizontal_spacing = math.sqrt(2) * horizontal_spacing
    vertical_spacing = horizontal_spacing * 0.5
end
local horizontal_cell_count = math.floor(image_width / (2 * horizontal_spacing)) + 1
local vertical_cell_count = math.floor(image_height / (2 * vertical_spacing))

if check_invert_tone then
    obj.effect("反転", "輝度反転", 1)
    highlight_color, shadow_color = shadow_color, highlight_color
end

obj.pixeloption("type", "yc")
local cell_scales = {}
local cell_alphas = {}
local cell_x_positions = {}
local cell_y_positions = {}
for i = -horizontal_cell_count, horizontal_cell_count do
    cell_scales[i] = {}
    cell_alphas[i] = {}
    cell_x_positions[i] = {}
    cell_y_positions[i] = {}
    for j = -vertical_cell_count, vertical_cell_count do
        local stagger_offset = 0
        if check_staggered then
            stagger_offset = vertical_spacing * (j % 2)
        end
        cell_x_positions[i][j] = i * horizontal_spacing + stagger_offset
        cell_y_positions[i][j] = j * vertical_spacing
        local luminance, chroma_blue, chroma_red, pixel_alpha =
            obj.getpixel(cell_x_positions[i][j] + image_width * 0.5, cell_y_positions[i][j] + image_height * 0.5, "yc")
        local tone_scale = math.sqrt(1 - luminance / 4096)
        tone_scale = minimum_tone_scale + tone_scale * tone_scale_range
        cell_scales[i][j] = tone_scale * 0.5
        cell_alphas[i][j] = pixel_alpha / 4095
    end
end
obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
if not check_hide_background_color then
    obj.effect("単色化", "color", highlight_color, "輝度を保持する", 0)
    obj.draw()
end
obj.load("figure", tone_figure, shadow_color, 2 * figure_size)
for i = -horizontal_cell_count, horizontal_cell_count do
    for j = -vertical_cell_count, vertical_cell_count do
        obj.draw(
            cell_x_positions[i][j],
            cell_y_positions[i][j],
            0,
            cell_scales[i][j],
            cell_alphas[i][j],
            0,
            0,
            rotation_degrees
        )
    end
end
if check_punch_out_self then
    obj.copybuffer("object", "cache:ori_img")
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
