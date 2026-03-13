--label:tim2\ぼかし\@T_RandomBlur_Module
---$track:最大ズレ量
---min=0
---max=5000
---step=0.1
local track_max_offset = 100

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 0

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$track:変化固定
---min=0
---max=1000
---step=1
local track_change_seed = 0

---$check:サイズ保持
local check_keep_size = true

--[[pixelshader@pal_rand_blur
---$include "./shaders/pal_rand_blur.hlsl"
]]

local max_offset = track_max_offset
local angle = track_angle
local change_seed = math.abs(math.floor(track_change_seed))
if change_seed == 0 then
    change_seed = math.floor(obj.time * obj.framerate)
end
local userdata, w, h
w, h = obj.getpixel()
if not check_keep_size then
    obj.setoption(
        "drawtarget",
        "tempbuffer",
        w + math.abs(2 * max_offset * math.cos(math.pi * angle / 180)),
        h + math.abs(2 * max_offset * math.sin(math.pi * angle / 180))
    )
    obj.draw()
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end
local angle_radians = math.pi * angle / 180
obj.pixelshader(
    "pal_rand_blur",
    "object",
    { "object", "random" },
    {
        max_offset,
        math.cos(angle_radians),
        math.sin(angle_radians),
        change_seed,
        track_base_position * 0.01
    }
)
