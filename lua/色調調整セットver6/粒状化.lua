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
local select_processing_method = 1

---$color:色1
local primary_color = 0xffffff

---$color: 色2
local secondary_color = 0x0

---$check:時間変動
local check_vary_seed_with_time = false

--hide@primary_color:select_processing_method==2
--hide@secondary_color:select_processing_method~=1

local seed = track_seed
if check_vary_seed_with_time then
    seed = obj.rand(0, 10000, -obj.time * obj.framerate, 1)
end

--[[pixelshader@grainy
---$include "./shaders/grainy.hlsl"
]]

local primary_red, primary_green, primary_blue = RGB(primary_color)
local secondary_red, secondary_green, secondary_blue = RGB(secondary_color)
obj.pixelshader("grainy", "object", { "object", "random" }, {
    track_amount,
    track_contrast,
    select_processing_method,
    seed,
    primary_red / 255,
    primary_green / 255,
    primary_blue / 255,
    secondary_red / 255,
    secondary_green / 255,
    secondary_blue / 255,
})
