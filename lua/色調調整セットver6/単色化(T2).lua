--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:U
---min=-500
---max=500
---step=0.1
local track_u = 5

---$track:V
---min=-500
---max=500
---step=0.1
local track_v = 5

---$track:ガンマ
---min=1
---max=1000
---step=0.1
local track_gamma = 100

---$check:参考表示
local check_show_reference = false

---$check:極座標指定
local check_use_polar_coordinates = 0

local u_offset = track_u * 0.01
local v_offset = track_v * 0.01
local gamma = track_gamma * 0.01
local polar_coordinate_mode = check_use_polar_coordinates or 0
if polar_coordinate_mode == 1 then
    v_offset = math.pi * track_v / 360
    u_offset, v_offset = u_offset * math.cos(v_offset), u_offset * math.sin(v_offset)
end

--[[pixelshader@monochromatic2
---$include "./shaders/monochromatic2.hlsl"
]]

if check_show_reference then
    obj.effect("リサイズ", "拡大率", 100 / 3)
    obj.copybuffer("cache:ORI", "object")
    local width, height = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", 3 * width, 3 * height)
    for i = -1, 1 do
        for j = -1, 1 do
            obj.copybuffer("object", "cache:ORI")
            obj.pixelshader("monochromatic2", "object", "object", {
                u_offset + i * 0.1,
                v_offset + j * 0.1,
                gamma,
            })
            obj.draw(width * i, -height * j, 0)
        end
    end
    obj.load("tempbuffer")
else
    obj.pixelshader("monochromatic2", "object", "object", {
        u_offset,
        v_offset,
        gamma,
    })
end
