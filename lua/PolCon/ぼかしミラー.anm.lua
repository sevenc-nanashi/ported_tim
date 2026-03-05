--label:tim2
---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local rename_me_track0 = 0

---$track:角度
---min=-360
---max=360
---step=0.1
local rename_me_track1 = 0

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local rename_me_track2 = 100

---$check:左右反転
local rename_me_check0 = true

local chk
if rename_me_check0 then
    chk = 1
else
    chk = 0
end
obj.setoption("drawtarget", "tempbuffer", obj.getpixel())
obj.draw()
obj.effect(
    "斜めクリッピング",
    "中心Y",
    rename_me_track0,
    "角度",
    rename_me_track1,
    "ぼかし",
    rename_me_track2
)
obj.effect("反転", "上下反転", 1, "左右反転", chk)
obj.draw()
obj.load("tempbuffer")
