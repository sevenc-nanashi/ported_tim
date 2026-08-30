--label:${ROOT_CATEGORY}\シーンチェンジ\@シーンチェンジセットT
---$track:ぼかし％
---min=0
---max=100
---step=0.1
local track_blur_percent = 10

---$check:透過反転
local check_invert_transparency = true

local blur_radius = 4096 * track_blur_percent * 0.01
local transition_progress = obj.getvalue("scenechange")
local luminance_threshold = (4096 + 2 * blur_radius) * transition_progress - blur_radius

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", "alpha_sub")

obj.effect("単色化")
if check_invert_transparency then
    obj.effect("反転", "輝度反転", 1)
end
obj.effect("ルミナンスキー", "基準輝度", luminance_threshold, "ぼかし", blur_radius, "type", 1)
obj.draw()

obj.copybuffer("object", "tempbuffer")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
