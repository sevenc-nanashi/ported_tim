--label:${ROOT_CATEGORY}\光効果\@ライトバースト
---$track:輝度
---min=0
---max=200
---step=0.1
local track_luminance = 100

---$track:コントラスト
---min=0
---max=100
---step=0.1
local track_contrast = 50

---$track:範囲
---min=0
---max=75
---step=0.1
local track_range = 50

---$track:透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$check:オリジナル色発光
local check_use_original_color = 0

---$color:発光色
local glow_color = 0xffffff

---$track:発光中心X
---min=-10000
---max=10000
---step=0.1
local track_glow_center_x = 0

---$track:発光中心Y
---min=-10000
---max=10000
---step=0.1
local track_glow_center_y = 0

--trackgroup@track_glow_center_x,track_glow_center_y:発光中心

---$select:合成モード
---通常=0
---加算=1
---減算=2
---乗算=3
---スクリーン=4
---オーバーレイ=5
---比較(明)=6
---比較(暗)=7
---輝度=8
---陰影=9
local select_blend_mode = 1

---$track:追加合成数
---min=0
---max=100
---step=1
local track_additional_blend_count = 0

---$track:サイズ補正X
---min=0
---max=5000
---step=1
local track_size_adjust_x = 0

---$track:サイズ補正Y
---min=0
---max=5000
---step=1
local track_size_adjust_y = 0

--hide@glow_color:check_use_original_color==1

local width, height = obj.getpixel()

width, height = width + track_size_adjust_x, height + track_size_adjust_y

obj.setoption("drawtarget", "tempbuffer", width, height)
obj.draw()

local center_x, center_y
if T_LIGHT_BURST_EXTERNAL_POSITION_ENABLED == nil or T_LIGHT_BURST_EXTERNAL_POSITION_ENABLED == 0 then
    obj.setanchor("track_glow_center_x,track_glow_center_y", 0)
    center_x = track_glow_center_x
    center_y = track_glow_center_y
else
    obj.load("tempbuffer")
    center_x = T_LIGHT_BURST_EXTERNAL_POSITION[1]
    center_y = T_LIGHT_BURST_EXTERNAL_POSITION[2]
end

if check_use_original_color == 0 then
    obj.effect("単色化", "color", glow_color)
end
obj.effect("色調補正", "輝度", track_luminance, "ｺﾝﾄﾗｽﾄ", 100 + track_contrast)
obj.effect("放射ブラー", "範囲", track_range, "X", center_x, "Y", center_y, "サイズ固定", 1)
obj.setoption("blend", select_blend_mode)
for i = 0, track_additional_blend_count do
    obj.draw(0, 0, 0, 1, 1 - track_opacity / 100)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
T_LIGHT_BURST_EXTERNAL_POSITION_ENABLED = 0
