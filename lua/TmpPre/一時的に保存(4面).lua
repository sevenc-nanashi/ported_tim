--label:tim2\一時保存読込.obj\一時的に保存(4面)
--track0:保存先,1,4,1,1
obj.load("framebuffer")
i = obj.track0
if set == nil or set == 0 then
    obj.setoption("dst", "tmp", 2 * obj.screen_w, 2 * obj.screen_h)
    set = 1
else
    obj.setoption("dst", "tmp")
end
obj.draw((((i - 1) % 2) - 0.5) * obj.screen_w, (math.floor((i - 1) / 2) - 0.5) * obj.screen_h, 0)
obj.copybuffer("cache:__ichijitekinihozon__", "tmp")
obj.alpha = 0
