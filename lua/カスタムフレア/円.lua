--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 300

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 50

---$track:ぼかし％
---min=0
---max=100
---step=0.1
local track_percent = 10

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local track_position_percent = 0

---$check:ベースカラー
local check_use_base_color = 1

---$color:色
local color = 0xccccff

---$value:位置ズレ％
local position_offset = { 0, 0, 0 }

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

--hide@color:check_use_base_color==1

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
if check_use_base_color == 1 then
    color = T_CUSTOM_FLARE_COLOR
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * track_intensity * 0.01
local size = track_size
local blur = track_percent
local position_percent = track_position_percent * 0.01
obj.load("figure", "円", color, 100)
obj.effect("ぼかし", "範囲", blur)
local draw_x = T_CUSTOM_FLARE_CENTER_X
    + position_percent * T_CUSTOM_FLARE_DELTA_X
    + position_offset[1] * T_CUSTOM_FLARE_DELTA_X * 0.01
local draw_y = T_CUSTOM_FLARE_CENTER_Y
    + position_percent * T_CUSTOM_FLARE_DELTA_Y
    + position_offset[2] * T_CUSTOM_FLARE_DELTA_Y * 0.01
local draw_z = T_CUSTOM_FLARE_CENTER_Z
    + position_percent * T_CUSTOM_FLARE_DELTA_Z
    + position_offset[3] * T_CUSTOM_FLARE_DELTA_Z * 0.01
obj.draw(draw_x, draw_y, draw_z, size / 100, alpha)
obj.load("tempbuffer")
obj.setoption("blend", 0)
