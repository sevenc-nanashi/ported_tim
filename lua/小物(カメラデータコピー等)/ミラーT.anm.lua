--label:${ROOT_CATEGORY}\配置
---$track:透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$track:境目調整
---min=-5000
---max=5000
---step=0.1
local track_border_adjust = 0

---$track:ぼかし
---min=0
---max=300
---step=0.1
local track_blur = 10

---$track:基準
---min=-100
---max=100
---step=0.1
local track_base = 100

---$color:色
local color_tint = nil

---$check:単色化(T)
local check_use_luminance_tint = 0

local alpha_ratio = 1 - track_opacity * 0.01
local border_offset = 2 * track_border_adjust
local blur_range = track_blur
local base_percent = track_base
local w, h = obj.getpixel()

if border_offset < -2 * h then
    border_offset = -2 * h
end

local reflected_height = h + border_offset

obj.setoption("drawtarget", "tempbuffer", w, h + reflected_height)

obj.draw(0, -reflected_height * 0.5, 0)

obj.effect("反転", "上下反転", 1)
obj.effect("ぼかし", "範囲", blur_range, "サイズ固定", 1)

if color_tint ~= nil then
    if check_use_luminance_tint == 0 then
        obj.effect("単色化", "color", color_tint)
    else
        obj.effect("単色化", "color", 0)
        obj.effect("グラデーション", "color", color_tint, "color2", color_tint, "blend", 1)
    end
end
if border_offset < 0 then
    obj.effect("斜めクリッピング", "角度", 180, "ぼかし", 0, "中心Y", -reflected_height * 0.5)
end

obj.draw(0, reflected_height * 0.5, 0, 1, alpha_ratio)
obj.load("tempbuffer")
obj.cy = obj.cy - reflected_height * base_percent * 0.005
