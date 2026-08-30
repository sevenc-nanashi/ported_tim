--label:${ROOT_CATEGORY}\装飾\@領域枠
---$track:画線幅
---min=0
---max=5000
---step=0.1
local track_stroke_width = 10

---$select:形状
---斜め=1
---円=2
---四角=3
---角丸=4
local select_shape = 1

---$track:切込量
---min=0
---max=5000
---step=0.1
local track_notch_amount = 20

---$track:背景濃度
---min=0
---max=100
---step=0.1
local track_background_density = 20

---$color:枠色
local color_border = 0xffffff

---$color:背景色
local color_background = 0xccccff

---$track:追加幅
---min=-5000
---max=5000
---step=0.1
local track_extra_width = 0

---$track:追加高さ
---min=-5000
---max=5000
---step=0.1
local track_extra_height = 0

---$value:基準
local value_origin_percent = { 0, 0 }

---$check:楕円
local check_use_ellipse = false

local function create_corner_cutout(
    max_dimension,
    half_width,
    half_height,
    notch_amount,
    stroke_width,
    corner_figure,
    base_figure
)
    obj.load("figure", base_figure, 0xffffff, 1.5 * max_dimension)
    local inner_half_width = half_width - stroke_width
    local inner_half_height = half_height - stroke_width
    inner_half_width = ((inner_half_width > 0) and inner_half_width) or 0
    inner_half_height = ((inner_half_height > 0) and inner_half_height) or 0
    obj.drawpoly(
        -inner_half_width,
        -inner_half_height,
        0,
        inner_half_width,
        -inner_half_height,
        0,
        inner_half_width,
        inner_half_height,
        0,
        -inner_half_width,
        inner_half_height,
        0
    )
    obj.load("figure", corner_figure, 0xffffff, notch_amount)
    obj.setoption("blend", "alpha_sub")
    obj.draw(half_width, half_height, 0, 0.5, 1, 0, 0, 0)
    obj.draw(-half_width, half_height, 0, 0.5, 1, 0, 0, 0)
    obj.draw(half_width, -half_height, 0, 0.5, 1, 0, 0, 0)
    obj.draw(-half_width, -half_height, 0, 0.5, 1, 0, 0, 0)
    obj.setoption("blend", 0)
end

local shape_drawers = {}
shape_drawers = {

    function(max_dimension, half_width, half_height, notch_amount, stroke_width, base_figure)
        obj.load("figure", base_figure, 0xffffff, 1.5 * max_dimension)
        local inner_half_width = half_width - stroke_width
        local inner_half_height = half_height - stroke_width
        inner_half_width = ((inner_half_width > 0) and inner_half_width) or 0
        inner_half_height = ((inner_half_height > 0) and inner_half_height) or 0
        obj.drawpoly(
            -inner_half_width,
            -inner_half_height,
            0,
            inner_half_width,
            -inner_half_height,
            0,
            inner_half_width,
            inner_half_height,
            0,
            -inner_half_width,
            inner_half_height,
            0
        )
        obj.copybuffer("object", "tempbuffer")
        local diagonal_clip_position = half_width + half_height - notch_amount - stroke_width * 2 ^ 0.5
        obj.effect("斜めクリッピング", "中心X", -diagonal_clip_position, "ぼかし", 0, "角度", 135)
        obj.effect("斜めクリッピング", "中心X", -diagonal_clip_position, "ぼかし", 0, "角度", 45)
        obj.effect("斜めクリッピング", "中心X", diagonal_clip_position, "ぼかし", 0, "角度", -135)
        obj.effect("斜めクリッピング", "中心X", diagonal_clip_position, "ぼかし", 0, "角度", -45)
        obj.copybuffer("tempbuffer", "object")
    end,
    function(max_dimension, half_width, half_height, notch_amount, stroke_width, base_figure)
        create_corner_cutout(
            max_dimension,
            half_width,
            half_height,
            4 * (notch_amount + stroke_width),
            stroke_width,
            "円",
            base_figure
        )
    end,
    function(max_dimension, half_width, half_height, notch_amount, stroke_width, base_figure)
        create_corner_cutout(
            max_dimension,
            half_width,
            half_height,
            4 * (notch_amount + stroke_width),
            stroke_width,
            "四角形",
            base_figure
        )
    end,
    function(max_dimension, half_width, half_height, notch_amount, stroke_width, base_figure)
        obj.load("figure", base_figure, 0xffffff, 1.5 * max_dimension)
        local inner_half_width = half_width - notch_amount + math.min(0, notch_amount - stroke_width)
        local inner_half_height = half_height - stroke_width
        inner_half_width = ((inner_half_width > 0) and inner_half_width) or 0
        inner_half_height = ((inner_half_height > 0) and inner_half_height) or 0
        obj.drawpoly(
            -inner_half_width,
            -inner_half_height,
            0,
            inner_half_width,
            -inner_half_height,
            0,
            inner_half_width,
            inner_half_height,
            0,
            -inner_half_width,
            inner_half_height,
            0
        )
        local inner_half_width = half_width - stroke_width
        local inner_half_height = half_height - notch_amount + math.min(0, notch_amount - stroke_width)
        inner_half_width = ((inner_half_width > 0) and inner_half_width) or 0
        inner_half_height = ((inner_half_height > 0) and inner_half_height) or 0
        obj.drawpoly(
            -inner_half_width,
            -inner_half_height,
            0,
            inner_half_width,
            -inner_half_height,
            0,
            inner_half_width,
            inner_half_height,
            0,
            -inner_half_width,
            inner_half_height,
            0
        )
        obj.load("figure", "円", 0xffffff, 8 * (notch_amount - stroke_width))
        local inner_half_width = half_width - notch_amount
        local inner_half_height = half_height - notch_amount
        inner_half_width = ((inner_half_width > 0) and inner_half_width) or 0
        inner_half_height = ((inner_half_height > 0) and inner_half_height) or 0
        obj.draw(inner_half_width, inner_half_height, 0, 0.25, 1)
        obj.draw(inner_half_width, -inner_half_height, 0, 0.25, 1)
        obj.draw(-inner_half_width, inner_half_height, 0, 0.25, 1)
        obj.draw(-inner_half_width, -inner_half_height, 0, 0.25, 1)
    end,
}

local function finalize_border_mask(max_dimension, color_border)
    obj.copybuffer("cache:cache-Itiji", "tempbuffer")
    obj.load("figure", "四角形", color_border, max_dimension + 10)
    obj.draw()
    obj.copybuffer("object", "cache:cache-Itiji")
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.setoption("blend", 0)
end

local w, h = obj.getpixel()
local stroke_width = track_stroke_width
local shape_index = select_shape
local notch_amount = track_notch_amount
local background_alpha = track_background_density * 0.01
value_origin_percent = value_origin_percent or { 0, 0 }
w, h = track_extra_width + w + 2 * stroke_width, track_extra_height + h + 2 * stroke_width

w = ((w > 0) and w) or 0
h = ((h > 0) and h) or 0

local max_dimension = math.max(w, h)
local half_width = w * 0.5
local half_height = h * 0.5

if shape_index == 4 then
    notch_amount = ((notch_amount < half_height) and notch_amount) or half_height
    notch_amount = ((notch_amount < half_width) and notch_amount) or half_width
end

local base_figure
if check_use_ellipse then
    base_figure = "円"
else
    base_figure = "四角形"
end

--オリジナル保存
obj.copybuffer("cache:cache-ori", "object")

--枠作成保存
obj.setoption("drawtarget", "tempbuffer", w + 10, h + 10)
shape_drawers[shape_index](max_dimension, half_width, half_height, notch_amount, stroke_width, base_figure)
finalize_border_mask(max_dimension, color_border)
obj.copybuffer("cache:cache-waku", "tempbuffer")

--削除領域作成保存
obj.setoption("drawtarget", "tempbuffer", w + 10, h + 10)
shape_drawers[shape_index](max_dimension, half_width, half_height, notch_amount, 0, base_figure)
finalize_border_mask(max_dimension, color_border)
obj.copybuffer("cache:cache-del", "tempbuffer")

--描画
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("figure", "四角形", color_background, max_dimension)
obj.draw(0, 0, 0, 1, background_alpha)

obj.copybuffer("object", "cache:cache-ori")
obj.draw()

obj.copybuffer("object", "cache:cache-waku")
obj.draw()

obj.copybuffer("object", "cache:cache-del")
obj.setoption("blend", "alpha_sub")
obj.draw()

obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.cx = obj.cx + w * value_origin_percent[1] * 0.01
obj.cy = obj.cy + h * value_origin_percent[2] * 0.01
