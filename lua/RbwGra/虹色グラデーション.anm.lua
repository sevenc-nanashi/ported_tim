--label:tim2\色調整

---$track:縮小率
---min=0
---max=500
---step=0.1
local track_shrink_rate = 100

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:シフト
---min=-5000
---max=5000
---step=0.1
local track_shift = 0

---$track:元画像の不透明度
---min=0
---max=100
---step=0.1
local track_original_image = 0

---$check:円形配置
local chk = 0

---$check:反転
local rev = 0

---$check:繰返し
local rep = 0

---$track:彩度
---min=0
---max=100
---step=0.1
local track_saturation = 30

---$track:境界補正
---min=0
---max=0.49
---step=0.001
local track_boundary_correction = 0.055

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
local track_blend_mode = 0

---$check:位置ズレ補正
local chk_position_correction = 1

local iox = obj.ox
local ioy = obj.oy
local icx = obj.cx
local icy = obj.cy

local tim2 = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()

tim2.rbwgra_r_gradation_line(
    userdata,
    w,
    h,
    track_saturation,
    track_shrink_rate * 0.01,
    math.rad(track_rotation),
    rev == 1,
    chk == 1,
    track_shift,
    rep == 1,
    track_boundary_correction
)

obj.putpixeldata("object", userdata, w, h, "bgra")
obj.setoption("blend", math.floor(track_blend_mode))
obj.draw(0, 0, 0, 1, 1 - track_original_image * 0.01)
obj.load("tempbuffer")
obj.setoption("blend", 0)

if chk_position_correction == 1 then
    obj.ox = iox
    obj.oy = ioy
    obj.cx = icx
    obj.cy = icy
end
