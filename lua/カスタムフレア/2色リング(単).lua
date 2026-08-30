--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 200

---$track:幅
---min=0
---max=4000
---step=0.1
local track_width = 20

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 80

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$check:ベースカラー
local check_use_base_color = 0

---$color:色1
local color_1 = 0xff0000

---$color:色2
local color_2 = 0x22ff22

---$track:グラデ幅
---min=0
---max=100
---step=0.1
local gradient_width = 40

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 5

---$track:開口量％
---min=0
---max=100
---step=0.1
local opening_percent = 40

---$track:開口ぼかし％
---min=0
---max=100
---step=0.1
local opening_blur_percent = 20

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = 25

---$value:位置オフセット
local position_offset = { 0, 0, 0 }

---$check:自動消去
local check_auto_hide = 0

---$track:基準距離
---min=0
---max=5000
---step=0.1
local reference_distance = 400

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

--hide@color_1:check_use_base_color==1
--hide@color_2:check_use_base_color==1
--hide@gradient_width:check_use_base_color==1
--hide@reference_distance:check_auto_hide==0

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * track_intensity * 0.01
if check_auto_hide == 1 then
    alpha = alpha
        * math.sqrt(
            T_CUSTOM_FLARE_DELTA_X * T_CUSTOM_FLARE_DELTA_X
                + T_CUSTOM_FLARE_DELTA_Y * T_CUSTOM_FLARE_DELTA_Y
                + T_CUSTOM_FLARE_DELTA_Z * T_CUSTOM_FLARE_DELTA_Z
        )
        / reference_distance
end
local circumference_length = track_size * math.pi / 4
local cy = (circumference_length - track_width * math.pi) * 0.5
local rotation = track_rotation + math.deg(math.atan2(T_CUSTOM_FLARE_DELTA_Y, T_CUSTOM_FLARE_DELTA_X)) - 90
position_percent = position_percent * 0.01
obj.load("figure", "四角形", T_CUSTOM_FLARE_COLOR, circumference_length)
obj.effect("斜めクリッピング", "角度", -180, "中心Y", cy)
if check_use_base_color == 0 then
    obj.effect(
        "グラデーション",
        "color",
        color_1,
        "color2",
        color_2,
        "中心Y",
        cy / 2 + circumference_length / 4,
        "幅",
        gradient_width
    )
end
if opening_percent > 0 then
    obj.effect(
        "斜めクリッピング",
        "角度",
        90,
        "幅",
        circumference_length * (100 - opening_percent) * 0.01,
        "ぼかし",
        circumference_length * opening_blur_percent * 0.01
    )
end
obj.effect("極座標変換")
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
obj.draw(draw_x, draw_y, draw_z, 1, alpha, 0, 0, rotation)
obj.load("tempbuffer")
obj.setoption("blend", 0)
