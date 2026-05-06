--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:量
---min=0
---max=100
---step=0.1
local track_amount = 50

---$track:ｺﾝﾄﾗｽﾄ
---min=-400
---max=400
---step=0.1
local track_contrast = 100

---$track:シード
---min=1
---max=10000
---step=1
local track_seed = 1

---$select:処理法
---A=1
---B=2
---C=3
local track_processing_method = 1

---$color:色1
local col1 = 0xffffff

---$color: 色2
local col2 = 0x0

---$check:時間変動
local check0 = false

local N = track_seed
if check0 then
    N = obj.rand(0, 10000, -obj.time * obj.framerate, 1)
end

--[[pixelshader@grainy
---$include "./shaders/grainy.hlsl"
]]

local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
obj.pixelshader("grainy", "object", { "object", "random" }, {
    track_amount,
    track_contrast,
    track_processing_method,
    N,
    r1 / 255,
    g1 / 255,
    b1 / 255,
    r2 / 255,
    g2 / 255,
    b2 / 255,
})
