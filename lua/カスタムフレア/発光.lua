--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:大きさ
---min=1
---max=5000
---step=0.1
local track_size = 80

---$track:ぼかし％
---min=1
---max=1000
---step=0.1
local track_percent = 10

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 30

---$track:中心強度
---min=0
---max=100
---step=0.1
local track_center_intensity = 100

---$check:ベースカラー
local check_use_base_color = 1

---$color:色
local color = 0xccccff

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = -100

---$value:位置オフセット％
local position_offset = { 0, 0, 0 }

---$track:発光中心サイズ％
---min=0
---max=100
---step=0.1
local size_falloff = 80

---$check:自動拡大
local check_auto_hide = 0

---$track:基準距離
---min=0
---max=5000
---step=0.1
local reference_distance = 400

--hide@color:check_use_base_color==1
--hide@reference_distance:check_auto_hide==0

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
if check_use_base_color == 1 then
    color = T_CUSTOM_FLARE_COLOR
end
local size = track_size
local intensity_ratio = track_intensity * 0.01
size_falloff = size_falloff * 0.01
if check_auto_hide == 1 then
    size = size
        * (
            1
            - math.sqrt(
                    T_CUSTOM_FLARE_DELTA_X * T_CUSTOM_FLARE_DELTA_X
                        + T_CUSTOM_FLARE_DELTA_Y * T_CUSTOM_FLARE_DELTA_Y
                        + T_CUSTOM_FLARE_DELTA_Z * T_CUSTOM_FLARE_DELTA_Z
                )
                / reference_distance
        )
    if size < 0 then
        size = 0
    end
end
local blur = size * track_percent * 0.01
local draw_x = (position_percent + position_offset[1]) * 0.01 * T_CUSTOM_FLARE_DELTA_X + T_CUSTOM_FLARE_CENTER_X
local draw_y = (position_percent + position_offset[2]) * 0.01 * T_CUSTOM_FLARE_DELTA_Y + T_CUSTOM_FLARE_CENTER_Y
local draw_z = (position_percent + position_offset[3]) * 0.01 * T_CUSTOM_FLARE_DELTA_Z + T_CUSTOM_FLARE_CENTER_Z
obj.load("figure", "円", color, size)
obj.effect("ぼかし", "範囲", blur)
obj.draw(draw_x, draw_y, draw_z, 1, intensity_ratio)
obj.load("figure", "円", 0xffffff, size * size_falloff)
obj.effect("ぼかし", "範囲", blur * size_falloff)
obj.draw(draw_x, draw_y, draw_z, 1, intensity_ratio * track_center_intensity * 0.01)
obj.load("tempbuffer")
obj.setoption("blend", 0)
