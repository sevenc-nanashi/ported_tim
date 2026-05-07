--label:${ROOT_CATEGORY}\加工
---$track:分割数
---min=10
---max=500
---step=0.1
local track_split_count = 80

---$track:ライン細％
---min=0
---max=100
---step=0.1
local track_percent = 10

---$track:ライン太％
---min=0
---max=100
---step=0.1
local track_percent_2 = 60

---$track:シフト
---min=-10000
---max=10000
---step=0.1
local track_shift = 0

---$color:ライン色
local Lcol = 0x000000

---$color:背景色
local Bcol = 0xffffff

---$check:背景色非表示
local bkap = 0

---$track:横分割倍率%
---min=1
---max=1000
---step=0.1
local bai = 200

---$check:反転
local rev = 0

--[[pixelshader@linetone_t
---$include "./shaders/linetone_t.hlsl"
]]

local spN = track_split_count
local spM = math.max(1, math.floor(spN * bai * 0.01))
local tsi1 = track_percent * 0.01
local tsi2 = math.max(track_percent_2 - track_percent, 0) * 0.01
local sf = track_shift

local w, h = obj.getpixel()
local sw = w / spM
local sh = h / spN
sf = sf % sh
obj.copybuffer("cache:ori_img", "obj")

obj.setoption("drawtarget", "tempbuffer", w, h)
obj.pixelshader("linetone_t", "tempbuffer", "cache:ori_img", {
    w,
    h,
    spM,
    spN,
    sw,
    sh,
    sf,
    tsi1,
    tsi2,
    rev,
    bkap,
    Lcol,
    Bcol,
})

obj.copybuffer("object", "cache:ori_img")
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", "none")
