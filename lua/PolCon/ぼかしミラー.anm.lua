--label:tim2\変形
---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local track_center_y = 0

---$track:角度
---min=-360
---max=360
---step=0.1
local track_angle = 0

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local track_blur = 100

---$check:左右反転
local check0 = true

local chk
if check0 then
    chk = 1
else
    chk = 0
end
obj.setoption("drawtarget", "tempbuffer", obj.getpixel())
obj.draw()
obj.effect(
    "斜めクリッピング",
    "中心Y",
    track_center_y,
    "角度",
    track_angle,
    "ぼかし",
    track_blur
)
obj.effect("反転", "上下反転", 1, "左右反転", chk)
obj.draw()
obj.load("tempbuffer")
