--label:${ROOT_CATEGORY}\オブジェクト制御\@一時保存読込EXT
---$track:保存先
---min=1
---max=1000
---step=1
local track_image_id = 0
---$check:非表示
local hide_source = false

local tim2 = obj.module("tim2")

local pixel_data, width, height = obj.getpixeldata("object")
tim2.extbuffer_save_buffer(track_image_id, pixel_data, width, height)

if hide_source then
    obj.alpha = 0
end
