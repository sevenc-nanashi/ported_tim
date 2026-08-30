--label:${ROOT_CATEGORY}\シーンチェンジ\@シーンチェンジセットT
---$track:サイズ
---min=1
---max=1000
---step=0.1
local track_tile_size = 50

---$check:タイル風
local check_tile_style = 0

---$check:タイル補正
local track_tile_correction = 1

---$check:滑らか
local track_smoothing = false

--hide@track_tile_correction:check_tile_style==0

local transition_progress = obj.getvalue("scenechange")
if track_smoothing then
    transition_progress = transition_progress * transition_progress * (3 - 2 * transition_progress)
end
local blend_alpha = 4 * transition_progress - 1.5
if blend_alpha < 0 then
    blend_alpha = 0
elseif blend_alpha > 1 then
    blend_alpha = 1
end
local mosaic_size = (track_tile_size - 1) * (1 - math.abs(2 * transition_progress - 1)) + 1
if check_tile_style == 1 and track_tile_correction == 1 and mosaic_size < 10 then
    obj.copybuffer("cache:bf", "object")
end
obj.copybuffer("tempbuffer", "frame")
obj.copybuffer("cache:af", "tempbuffer")

obj.effect("モザイク", "サイズ", mosaic_size, "タイル風", check_tile_style)
obj.draw()
obj.copybuffer("object", "cache:af")
obj.effect("モザイク", "サイズ", mosaic_size, "タイル風", check_tile_style)
obj.draw(0, 0, 0, 1, blend_alpha)

if check_tile_style == 1 and track_tile_correction == 1 and mosaic_size < 10 then
    local image_width, image_height = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
    obj.copybuffer("object", "cache:bf")
    obj.effect("モザイク", "サイズ", mosaic_size)
    obj.draw()
    obj.copybuffer("object", "cache:af")
    obj.effect("モザイク", "サイズ", mosaic_size)
    obj.draw(0, 0, 0, 1, blend_alpha)
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
    obj.draw(0, 0, 0, 1, (10 - mosaic_size) / 9)
end
