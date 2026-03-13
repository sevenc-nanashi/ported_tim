--label:tim2\変形
---$track:変換範囲
---min=0
---max=100
---step=0.1
local track_range = 100

---$track:適用度
---min=0
---max=100
---step=0.1
local track_apply_amount = 100

---$track:逆変換
---min=0
---max=1
---step=1
local track_inverse_transform = 0

local tim2 = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
obj.clearbuffer("cache:work", w, h)
local work = obj.getpixeldata("cache:work", "bgra")
if track_inverse_transform == 0 then
    tim2.polcon_polar_conversion(userdata, work, w, h, track_range * 0.01, track_apply_amount * 0.01)
else
    tim2.polcon_polar_inversion(userdata, work, w, h, track_range * 0.01, track_apply_amount * 0.01)
end
obj.putpixeldata("object", userdata, w, h, "bgra")
