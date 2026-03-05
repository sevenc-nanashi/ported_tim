--label:tim2\T_Color_Module.anm
---$track:中心
---min=-255
---max=255
---step=0.1
local track_center = 0

---$track:強度
---min=-200
---max=200
---step=0.1
local track_intensity = 100

---$track:明るさ
---min=-255
---max=255
---step=0.1
local track_brightness = 0

---$track:なめらか
---min=0
---max=100
---step=0
local track_smooth = 50

---$value:カーブサイズ
local Csiz = 260

---$check:カーブ表示
local check0 = true

require("T_Color_Module")
if check0 then
    obj.load("figure", "四角形", 0xffffff, math.max(100, Csiz or 260))
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ExtendedContrast(
    userdata,
    w,
    h,
    track_center,
    track_intensity,
    track_brightness,
    track_smooth / 100,
    check0
)
obj.putpixeldata(userdata)
