--label:${ROOT_CATEGORY}\シーンチェンジ\@シーンチェンジセットT
---$track:単独量
---min=0
---max=100
---step=0.1
local track_single_amount = 40

---$select:モード
---通常=0
---逆順=1
---交互=2
---逆順・交互=3
local select_mode = 1

---$track:分割数
---min=2
---max=100
---step=1
local track_split_count = 5

---$check:縦
local check_vertical = false

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", "alpha_sub")

local transition_progress = obj.getvalue("scenechange")
local segment_duration = track_single_amount * 0.01
local split_count = math.max(2, math.floor(track_split_count))
local selected_mode = math.floor(select_mode)
local reverse_order = selected_mode % 2 == 1
local alternate_direction = selected_mode >= 2
local overlap_duration = (split_count * segment_duration - 1) / (split_count - 1)
if overlap_duration <= 0 then
    overlap_duration = 0
end

local image_width = obj.w
local image_height = obj.h
local half_width = 0.5 * image_width
local half_height = 0.5 * image_height

if check_vertical then
    for segment_index = 1, split_count do
        local order_index = segment_index
        if reverse_order then
            order_index = split_count - segment_index + 1
        end

        local x0 = (segment_index - 1) * image_width / split_count - half_width
        local x1 = segment_index * image_width / split_count - half_width
        if (order_index - 1) * (segment_duration - overlap_duration) + segment_duration <= transition_progress then --全表示
            obj.drawpoly(x0, -half_height, 0, x1, -half_height, 0, x1, image_height, 0, x0, image_height, 0)
        else
            local revealed_height = (transition_progress - (order_index - 1) * (segment_duration - overlap_duration))
                * image_height
                / segment_duration
            if revealed_height <= 0 then
                revealed_height = 0
            end
            if alternate_direction and segment_index % 2 == 0 then
                obj.drawpoly(
                    x0,
                    half_height - revealed_height,
                    0,
                    x1,
                    half_height - revealed_height,
                    0,
                    x1,
                    half_height,
                    0,
                    x0,
                    half_height,
                    0
                )
            else
                obj.drawpoly(
                    x0,
                    -half_height,
                    0,
                    x1,
                    -half_height,
                    0,
                    x1,
                    revealed_height - half_height,
                    0,
                    x0,
                    revealed_height - half_height,
                    0
                )
            end
        end
    end --k
else
    for segment_index = 1, split_count do
        local order_index = segment_index
        if reverse_order then
            order_index = split_count - segment_index + 1
        end

        local y0 = (segment_index - 1) * image_height / split_count - half_height
        local y1 = segment_index * image_height / split_count - half_height
        if (order_index - 1) * (segment_duration - overlap_duration) + segment_duration <= transition_progress then --全表示
            obj.drawpoly(-half_width, y0, 0, half_width, y0, 0, half_width, y1, 0, -half_width, y1, 0)
        else
            local revealed_width = (transition_progress - (order_index - 1) * (segment_duration - overlap_duration))
                * image_width
                / segment_duration
            if revealed_width <= 0 then
                revealed_width = 0
            end
            if alternate_direction and segment_index % 2 == 0 then
                obj.drawpoly(
                    half_width - revealed_width,
                    y0,
                    0,
                    half_width,
                    y0,
                    0,
                    half_width,
                    y1,
                    0,
                    half_width - revealed_width,
                    y1,
                    0
                )
            else
                obj.drawpoly(
                    -half_width,
                    y0,
                    0,
                    revealed_width - half_width,
                    y0,
                    0,
                    revealed_width - half_width,
                    y1,
                    0,
                    -half_width,
                    y1,
                    0
                )
            end
        end
    end --k
end
obj.copybuffer("object", "tempbuffer")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
