--label:${ROOT_CATEGORY}\シーンチェンジ\@シーンチェンジセットT
---$track:ブラー量
---min=0
---max=5000
---step=0.1
local track_blur_amount = 50

---$select:流れ方向
---横=0
---縦=1
local select_flow_direction = 0

---$track:分割数
---min=1
---max=100
---step=1
local track_split_count = 20

local calculate_warp_position = function(frame_position, half_frame_count)
    local normalized_position

    if half_frame_count > 2 then
        local mirrored_position = frame_position
        if frame_position > half_frame_count * 0.5 then
            mirrored_position = half_frame_count - frame_position
        end
        if mirrored_position > 0.5 then
            normalized_position = 0.25
                + (math.sqrt((8 * mirrored_position - 4) * (half_frame_count - 2) + 1) - 1)
                    / (8 * (half_frame_count - 2))
        else
            normalized_position = mirrored_position * 0.5
        end
        if frame_position > half_frame_count * 0.5 then
            normalized_position = 1 - normalized_position
        end
    else
        normalized_position = frame_position / half_frame_count
    end

    return normalized_position
end

local blur_range = track_blur_amount * 0.5
local flow_direction = math.floor(select_flow_direction)
local split_count = math.floor(track_split_count)

local last_frame = obj.totalframe - 1
local half_frame_count = (last_frame + 2) * 0.5
local frame_position = obj.frame -- math.floor(obj.getvalue("scenechange") * TF)

local image_width, image_height = obj.getpixel()
local half_width, half_height = image_width / 2, image_height / 2

obj.copybuffer("cache:ch", "object")
obj.copybuffer("cache:after", "framebuffer")
obj.setoption("drawtarget", "tempbuffer", image_width, image_height)

if flow_direction == 0 then
    obj.drawpoly(-half_width, -half_height, 0, 0, -half_height, 0, 0, half_height, 0, -half_width, half_height, 0)
    obj.copybuffer("object", "cache:after")
    obj.drawpoly(0, -half_height, 0, half_width, -half_height, 0, half_width, half_height, 0, 0, half_height, 0)
    obj.copybuffer("object", "tempbuffer")
    obj.effect("方向ブラー", "範囲", blur_range, "角度", -90, "サイズ固定", 1)
    local normalized_segment_width = 1 / split_count
    local segment_width = image_width / split_count
    for i = 0, split_count - 1 do
        local x0 = frame_position * 0.5 + i * normalized_segment_width
        local x1 = x0 + normalized_segment_width
        local u0 = image_width * calculate_warp_position(x0, half_frame_count)
        local u1 = image_width * calculate_warp_position(x1, half_frame_count)
        x0 = -half_width + i * segment_width
        x1 = x0 + segment_width
        obj.drawpoly(
            x0,
            -half_height,
            0,
            x1,
            -half_height,
            0,
            x1,
            half_height,
            0,
            x0,
            half_height,
            0,
            u0,
            0,
            u1,
            0,
            u1,
            image_height,
            u0,
            image_height
        )
    end
    if frame_position == 0 then
        obj.copybuffer("object", "cache:ch")
        obj.effect("斜めクリッピング", "角度", -90, "ぼかし", image_width / 3, "中心X", -image_width / 6)
        obj.draw()
    end
    if frame_position == last_frame then
        obj.load("framebuffer")
        obj.effect("斜めクリッピング", "角度", 90, "ぼかし", image_width / 3, "中心X", image_width / 6)
        obj.draw()
    end
else
    obj.drawpoly(-half_width, -half_height, 0, half_width, -half_height, 0, half_width, 0, 0, -half_width, 0, 0)
    obj.copybuffer("object", "frame")
    obj.drawpoly(-half_width, 0, 0, half_width, 0, 0, half_width, half_height, 0, -half_width, half_height, 0)
    obj.copybuffer("object", "tempbuffer")
    obj.effect("方向ブラー", "範囲", blur_range, "角度", 0, "サイズ固定", 1)
    local normalized_segment_height = 1 / split_count
    local segment_height = image_height / split_count
    for i = 0, split_count - 1 do
        local y0 = frame_position * 0.5 + i * normalized_segment_height
        local y1 = y0 + normalized_segment_height
        local v0 = image_height * calculate_warp_position(y0, half_frame_count)
        local v1 = image_height * calculate_warp_position(y1, half_frame_count)
        y0 = -half_height + i * segment_height
        y1 = y0 + segment_height
        obj.drawpoly(
            -half_width,
            y0,
            0,
            half_width,
            y0,
            0,
            half_width,
            y1,
            0,
            -half_width,
            y1,
            0,
            0,
            v0,
            image_width,
            v0,
            image_width,
            v1,
            0,
            v1
        )
    end
    if frame_position == 0 then
        obj.copybuffer("object", "cache:ch")
        obj.effect("斜めクリッピング", "角度", 0, "ぼかし", image_height / 3, "中心Y", -image_height / 6)
        obj.draw()
    end
    if frame_position == last_frame then
        obj.load("framebuffer")
        obj.effect(
            "斜めクリッピング",
            "角度",
            180,
            "ぼかし",
            image_height / 3,
            "中心Y",
            image_height / 6
        )
        obj.draw()
    end
end

obj.copybuffer("object", "tempbuffer")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
