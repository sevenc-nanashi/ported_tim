--label:${ROOT_CATEGORY}\ぼかし\@T_RotBlur_Module
---$track:中心X
---min=-5000
---max=5000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local track_center_y = 0

--trackgroup@track_center_x,track_center_y:中心

---$track:渦量
---min=-3000
---max=3600
---step=0.1
local track_swirl_amount = 100

---$select:変化
---二乗減衰=0
---指数減衰=1
local select_change_mode = 0

---$check:サイズ保持
local check_keep_size = true

--[[pixelshader@whirlpool
---$include "./shaders/whirlpool.hlsl"
]]

local is_enabled = function(value)
    return value == true or value == 1
end

obj.setanchor("track_center_x,track_center_y", 0, "line")
local center_x = track_center_x
local center_y = track_center_y
local swirl_amount = track_swirl_amount
local change_mode = select_change_mode
local image_width, image_height = obj.getpixel()
local image_diagonal = math.sqrt(image_width * image_width + image_height * image_height)
if not is_enabled(check_keep_size) then
    local add_x, add_y =
        math.ceil((image_diagonal - image_width) / 2 + 1), math.ceil((image_diagonal - image_height) / 2 + 1)
    obj.effect("領域拡張", "上", add_y, "下", add_y, "右", add_x, "左", add_x)
end

image_width, image_height = obj.getpixel()
if image_width > 0 and image_height > 0 then
    obj.pixelshader("whirlpool", "object", "object", {
        swirl_amount,
        image_diagonal / 2,
        center_x,
        center_y,
        change_mode,
    })
end
