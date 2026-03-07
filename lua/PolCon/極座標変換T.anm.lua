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

require("T_PolarConversion_Module")
local userdata, w, h = obj.getpixeldata()
local work = obj.getpixeldata("work")
local LUD
if track_inverse_transform == 0 then
    LUD = T_PolarConversion_Module.PolarConversion(userdata, work, w, h, track_range * 0.01, track_apply_amount * 0.01)
else
    LUD = T_PolarConversion_Module.PolarInversion(userdata, work, w, h, track_range * 0.01, track_apply_amount * 0.01)
end
obj.putpixeldata(LUD)
