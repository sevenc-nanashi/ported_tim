--label:${ROOT_CATEGORY}\オブジェクト制御\@一時保存読込
---$track:読込先
---min=1
---max=4
---step=1
local track_load_target = 1

---$check:中心調整
local check_adjust_center = true

local panel_index = track_load_target
obj.copybuffer("object", "cache:__ichijitekinihozon__")
if not check_adjust_center then
    if panel_index == 1 then
        obj.effect("クリッピング", "右", obj.screen_w, "下", obj.screen_h)
        obj.ox = obj.screen_w / 2
        obj.oy = obj.screen_h / 2
    elseif panel_index == 2 then
        obj.effect("クリッピング", "左", obj.screen_w, "下", obj.screen_h)
        obj.ox = -obj.screen_w / 2
        obj.oy = obj.screen_h / 2
    elseif panel_index == 3 then
        obj.effect("クリッピング", "右", obj.screen_w, "上", obj.screen_h)
        obj.ox = obj.screen_w / 2
        obj.oy = -obj.screen_h / 2
    else
        obj.effect("クリッピング", "左", obj.screen_w, "上", obj.screen_h)
        obj.ox = -obj.screen_w / 2
        obj.oy = -obj.screen_h / 2
    end
else
    if panel_index == 1 then
        obj.effect("クリッピング", "右", obj.screen_w, "下", obj.screen_h, "中心の位置を変更", 1)
    elseif panel_index == 2 then
        obj.effect("クリッピング", "左", obj.screen_w, "下", obj.screen_h, "中心の位置を変更", 1)
    elseif panel_index == 3 then
        obj.effect("クリッピング", "右", obj.screen_w, "上", obj.screen_h, "中心の位置を変更", 1)
    else
        obj.effect("クリッピング", "左", obj.screen_w, "上", obj.screen_h, "中心の位置を変更", 1)
    end
end

T_TEMP_IMAGE_FOUR_PANEL_INITIALIZED = 0
