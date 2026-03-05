--label:tim2\一時保存読込.obj\保存画像の読込(4面)
--track0:読込先,1,4,1,1
--check0:中心調整,1;

i = obj.track0
obj.copybuffer("obj", "cache:__ichijitekinihozon__")
if not obj.check0 then
    if i == 1 then
        obj.effect("クリッピング", "右", obj.screen_w, "下", obj.screen_h)
        obj.ox = obj.screen_w / 2
        obj.oy = obj.screen_h / 2
    elseif i == 2 then
        obj.effect("クリッピング", "左", obj.screen_w, "下", obj.screen_h)
        obj.ox = -obj.screen_w / 2
        obj.oy = obj.screen_h / 2
    elseif i == 3 then
        obj.effect("クリッピング", "右", obj.screen_w, "上", obj.screen_h)
        obj.ox = obj.screen_w / 2
        obj.oy = -obj.screen_h / 2
    else
        obj.effect("クリッピング", "左", obj.screen_w, "上", obj.screen_h)
        obj.ox = -obj.screen_w / 2
        obj.oy = -obj.screen_h / 2
    end
else
    if i == 1 then
        obj.effect("クリッピング", "右", obj.screen_w, "下", obj.screen_h, "中心の位置を変更", 1)
    elseif i == 2 then
        obj.effect("クリッピング", "左", obj.screen_w, "下", obj.screen_h, "中心の位置を変更", 1)
    elseif i == 3 then
        obj.effect("クリッピング", "右", obj.screen_w, "上", obj.screen_h, "中心の位置を変更", 1)
    else
        obj.effect("クリッピング", "左", obj.screen_w, "上", obj.screen_h, "中心の位置を変更", 1)
    end
end

set = 0
