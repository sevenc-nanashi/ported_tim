--label:${ROOT_CATEGORY}\色調整\@多色グラデーション
local color_index
---$track:番号
---min=1
---max=8
---step=1
local track_index = 1

---$track:幅
---min=-5000
---max=5000
---step=0.1
local track_width = 0

---$track:中心X
---min=-20000
---max=20000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-20000
---max=20000
---step=0.1
local track_center_y = 0

if T_GRADIENT_EXTENSION_ACTIVE == nil or T_GRADIENT_EXTENSION_ACTIVE == 0 then
    T_GRADIENT_OFFSET_X = { 0, 0, 0, 0, 0, 0, 0, 0 }
    T_GRADIENT_OFFSET_Y = { 0, 0, 0, 0, 0, 0, 0, 0 }
    T_GRADIENT_WIDTH_OFFSETS = { 0, 0, 0, 0, 0, 0, 0, 0 }
end
color_index = math.floor(track_index)
T_GRADIENT_WIDTH_OFFSETS[color_index] = track_width
T_GRADIENT_OFFSET_X[color_index] = track_center_x
T_GRADIENT_OFFSET_Y[color_index] = track_center_y
T_GRADIENT_EXTENSION_ACTIVE = 1
