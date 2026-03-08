--label:tim2\加工\T_Filter_Module.anm
--group:前処理,true

---$track:木炭適用
---min=0
---max=100
---step=0.1
local track_charcoal_apply = 0

---$track:チョーク適用
---min=0
---max=100
---step=0.1
local track_chalk_apply = 0

---$track:筆圧
---min=0
---max=100
---step=0.1
local track_pen_pressure = 50

---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 0

---$check:しきい値を自動計算
local auto_threshold = true

--group:

--group:仕上げ,true

---$track:長さ
---min=1
---max=10
---step=1
local track_length = 7

---$track:ノイズ強度
---min=0
---max=100
---step=0.1
local track_noise_power = 30

---$color:シャドウ
local color_shadow = 0x0

---$color:ハイライト
local color_highlight = 0xffffff

---$check:シード固定
local fix_seed = true

---$track:シード
---min=0
---max=100000
---step=1
local track_seed = 0

--group:

local T_Filter_Module = obj.module("tim2")
local seed = track_seed
local length = track_length

if not fix_seed then
    seed = seed + obj.time * obj.framerate
end
if length < 1 then
    length = 1
elseif length > 10 then
    length = 10
end

obj.effect("単色化")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Filter_Module.filter_preprocessing(
    userdata,
    w,
    h,
    track_charcoal_apply * 0.01,
    track_chalk_apply * 0.01,
    track_pen_pressure * 0.01,
    track_threshold,
    auto_threshold
)
obj.putpixeldata("object", userdata, w, h, "bgra")
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.effect("単色化", "輝度を保持する", 0)
obj.effect("ノイズ", "強さ", 100, "周期X", 50, "周期Y", 50, "type", 0, "mode", 1, "seed", seed)
obj.effect("ぼかし", "範囲", 3, "サイズ固定", 1)
obj.setoption("blend", 5)
obj.draw(0, 0, 0, 1, track_noise_power * 0.01)
obj.load("tempbuffer")
userdata, w, h = obj.getpixeldata("object", "bgra")
local r1, g1, b1 = RGB(color_shadow)
local r2, g2, b2 = RGB(color_highlight)
T_Filter_Module.filter_chalk_charcoal(userdata, w, h, length, r1, g1, b1, r2, g2, b2)
obj.putpixeldata("object", userdata, w, h, "bgra")
obj.setoption("blend", 0)