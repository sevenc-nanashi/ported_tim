--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:色数
---min=1
---max=512
---step=1
local track_color_count = 16

---$track:X分割
---min=1
---max=20
---step=1
local track_x_split = 4

---$track:Y分割
---min=1
---max=20
---step=1
local track_y_split = 4

T_CLUSTER_REDUCTION_PALETTE = {}
local color_count = track_color_count
local column_count = track_x_split
local row_count = track_y_split
local width, height = obj.getpixel()
local cell_width, cell_height = width / column_count, height / row_count
T_CLUSTER_REDUCTION_PALETTE.colors = {}
local color_index = 0
for j = 0, row_count - 1 do
    for i = 0, column_count - 1 do
        color_index = color_index + 1
        if color_index <= color_count then
            local sampled_color, pixel_alpha = obj.getpixel((i + 0.5) * cell_width, (j + 0.5) * cell_height, "col")
            T_CLUSTER_REDUCTION_PALETTE.colors[color_index] = sampled_color
        end
    end
end
T_CLUSTER_REDUCTION_PALETTE.count = color_count
obj.setoption("drawtarget", "tempbuffer", obj.w, obj.h)
obj.copybuffer("tempbuffer", "object")
obj.load("figure", "四角形", 0xff0000, 6, 1)
color_index = 0
for j = 0, row_count - 1 do
    for i = 0, column_count - 1 do
        color_index = color_index + 1
        if color_index <= color_count then
            obj.draw((i + 0.5) * cell_width - width * 0.5, (j + 0.5) * cell_height - 0.5 * height)
        end
    end
end
obj.copybuffer("object", "tempbuffer")
