--label:${ROOT_CATEGORY}\装飾\@領域枠
---$track:画線幅
---min=0
---max=5000
---step=0.1
local track_stroke_width = 10

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

---$track:背景濃度
---min=0
---max=100
---step=0.1
local track_background_density = 20

---$color:枠色
local color_border = 0xffffff

---$color:背景色
local color_background = 0xccccff

---$value:基準
local value_origin_percent = { 0, 0 }

obj.copybuffer("cache:cache1", "object")
local w, h = obj.getpixel()
local stroke_width = track_stroke_width
local extra_width = track_extra_width
local extra_height = track_extra_height
local background_alpha = track_background_density * 0.01
local w, h = extra_width + w + 2 * stroke_width, extra_height + h + 2 * stroke_width
w = ((w > 1) and w) or 1
h = ((h > 1) and h) or 1
value_origin_percent = value_origin_percent or { 0, 0 }
obj.setoption("drawtarget", "tempbuffer", w, h)
local max_dimension = math.max(w, h)
obj.load("figure", "四角形", color_background, max_dimension)
obj.draw(0, 0, 0, 1, background_alpha)
obj.copybuffer("object", "cache:cache1")
obj.draw()
obj.load("figure", "四角形", color_border, max_dimension)
if stroke_width > 0 then
    local half_width = w * 0.5
    local half_height = h * 0.5
    local inner_half_width = half_width - stroke_width
    local inner_half_height = half_height - stroke_width
    inner_half_width = ((inner_half_width > 0) and inner_half_width) or 0
    inner_half_height = ((inner_half_height > 0) and inner_half_height) or 0
    obj.drawpoly(
        -half_width,
        -half_height,
        0,
        half_width,
        -half_height,
        0,
        half_width,
        -inner_half_height,
        0,
        -half_width,
        -inner_half_height,
        0
    )
    obj.drawpoly(
        -half_width,
        inner_half_height,
        0,
        half_width,
        inner_half_height,
        0,
        half_width,
        half_height,
        0,
        -half_width,
        half_height,
        0
    )
    obj.drawpoly(
        inner_half_width,
        -half_height,
        0,
        half_width,
        -half_height,
        0,
        half_width,
        half_height,
        0,
        inner_half_width,
        half_height,
        0
    )
    obj.drawpoly(
        -half_width,
        -half_height,
        0,
        -inner_half_width,
        -half_height,
        0,
        -inner_half_width,
        half_height,
        0,
        -half_width,
        half_height,
        0
    )
end
obj.load("tempbuffer")
obj.cx = obj.cx + w * value_origin_percent[1] * 0.01
obj.cy = obj.cy + h * value_origin_percent[2] * 0.01
