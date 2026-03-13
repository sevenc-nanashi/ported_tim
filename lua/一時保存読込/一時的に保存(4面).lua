--label:tim2\オブジェクト制御\@一時保存読込.obj
---$track:保存先
---min=1
---max=4
---step=1
local track_save_target = 1

obj.load("framebuffer")
i = track_save_target
if set == nil or set == 0 then
    obj.setoption("dst", "tmp", 2 * obj.screen_w, 2 * obj.screen_h)
    set = 1
else
    obj.setoption("dst", "tmp")
end
obj.draw((((i - 1) % 2) - 0.5) * obj.screen_w, (math.floor((i - 1) / 2) - 0.5) * obj.screen_h, 0)
obj.copybuffer("cache:__ichijitekinihozon__", "tempbuffer")
obj.alpha = 0
