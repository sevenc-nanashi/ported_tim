--label:${ROOT_CATEGORY}\変形\@サイズ修正T
---$track:横
---min=0
---max=5000
---step=0.1
local width = 320

---$track:縦
---min=0
---max=5000
---step=0.1
local height = 180

---$track:基準X[%]
---min=-100
---max=100
---step=0.1
local center_x = 0

---$track:基準Y[%]
---min=-100
---max=100
---step=0.1
local center_y = 0

local half_width = width * 0.5
local half_height = height * 0.5
local center_offset_x = half_width * center_x * 0.01
local center_offset_y = half_height * center_y * 0.01

obj.setoption("drawtarget", "tempbuffer", 2 * half_width + 2, 2 * half_height + 2)
obj.drawpoly(
    -half_width,
    -half_height,
    0,
    half_width,
    -half_height,
    0,
    half_width,
    half_height,
    0,
    -half_width,
    half_height,
    0
)
obj.load("tempbuffer")
obj.cx = center_offset_x
obj.cy = center_offset_y
