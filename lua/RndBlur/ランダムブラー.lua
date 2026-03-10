--label:tim2\ぼかし\T_RandomBlur_Module.anm
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

local max_offset = track_max_offset
local angle = track_angle
local change_seed = track_change_seed
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
local tim2 = obj.module("tim2")
userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.rndblur_pal_rand_blur(userdata, w, h, max_offset, angle, change_seed, track_base_position * 0.01)
obj.putpixeldata("object", userdata, w, h, "bgra")
