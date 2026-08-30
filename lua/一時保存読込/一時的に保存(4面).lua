--label:${ROOT_CATEGORY}\オブジェクト制御\@一時保存読込
---$track:保存先
---min=1
---max=4
---step=1
local track_save_target = 1

obj.load("framebuffer")
local panel_index = track_save_target
if T_TEMP_IMAGE_FOUR_PANEL_INITIALIZED == nil or T_TEMP_IMAGE_FOUR_PANEL_INITIALIZED == 0 then
    obj.setoption("drawtarget", "tempbuffer", 2 * obj.screen_w, 2 * obj.screen_h)
    T_TEMP_IMAGE_FOUR_PANEL_INITIALIZED = 1
else
    obj.setoption("drawtarget", "tempbuffer")
end
obj.draw((((panel_index - 1) % 2) - 0.5) * obj.screen_w, (math.floor((panel_index - 1) / 2) - 0.5) * obj.screen_h, 0)
obj.copybuffer("cache:__ichijitekinihozon__", "tempbuffer")
obj.alpha = 0
