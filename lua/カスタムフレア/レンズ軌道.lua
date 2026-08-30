--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:密度
---min=1
---max=100
---step=0.1
local track_density = 10

---$track:サイズ％
---min=0
---max=50
---step=0.1
local track_size_percent = 15

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 15

---$track:減衰率
---min=0
---max=100
---step=0.1
local track_attenuation_rate = 40

---$figure:形状
local particle_shape = "円"

---$track:サイズ幅％
---min=0
---max=100
---step=0.1
local size_randomness = 10

---$track:強度幅％
---min=0
---max=100
---step=0.1
local alpha_randomness = 0

---$check:ベースカラー
local check_use_base_color = 1

---$color:色
local color = 0xccccff

---$track:色幅％
---min=0
---max=100
---step=0.1
local color_randomness = 0

---$track:回転
---min=-3600
---max=3600
---step=0.1
local base_rotation = 0

---$track:回転幅
---min=-3600
---max=3600
---step=0.1
local rotation_randomness = 0

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 0

---$track:乱数シード
---min=0
---max=100000
---step=1
local seed = 0

--hide@color:check_use_base_color==1

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
if check_use_base_color == 1 then
    color = T_CUSTOM_FLARE_COLOR
end
local size = T_CUSTOM_FLARE_WIDTH * track_size_percent * 0.01
local intensity = track_intensity * 0.01
local attenuation = track_attenuation_rate * 0.01
obj.load("figure", particle_shape, color, size)
obj.effect("ぼかし", "範囲", blur)
local horizontal_count = math.floor(T_CUSTOM_FLARE_WIDTH / 600 * track_density)
local vertical_count = math.floor(T_CUSTOM_FLARE_HEIGHT / 600 * track_density)
attenuation = -200 * attenuation / (T_CUSTOM_FLARE_WIDTH * T_CUSTOM_FLARE_WIDTH)
local cell_size = T_CUSTOM_FLARE_WIDTH / horizontal_count
local position_randomness = cell_size * 0.5
for i = 0, horizontal_count do
    for j = 0, vertical_count do
        if color_randomness > 0 then
            local h, s, v = HSV(color)
            h = math.floor(h + math.floor(3.6 * obj.rand(0, color_randomness, i, j + seed))) % 360
            color = HSV(h, s, v)
            obj.load("figure", particle_shape, color, size)
            obj.effect("ぼかし", "範囲", blur)
        end
        local zoom = 1 - obj.rand(0, size_randomness, i, j + 4000 + seed) * 0.01
        local alpha = intensity * obj.rand(100 - alpha_randomness, 100, i, j + 6000 + seed) * 0.01
        local ox = i * cell_size
            - T_CUSTOM_FLARE_WIDTH * 0.5
            + obj.rand(-position_randomness, position_randomness, i, j + 1000 + seed)
        local oy = j * cell_size
            - T_CUSTOM_FLARE_HEIGHT * 0.5
            + obj.rand(-position_randomness, position_randomness, i, j + 2000 + seed)
        local rr = (ox - T_CUSTOM_FLARE_SOURCE_X) * (ox - T_CUSTOM_FLARE_SOURCE_X)
            + (oy - T_CUSTOM_FLARE_SOURCE_Y) * (oy - T_CUSTOM_FLARE_SOURCE_Y)
        alpha = alpha * math.exp(attenuation * rr)
        local rz = base_rotation + obj.rand(-rotation_randomness, rotation_randomness, i, j + 7000 + seed)
        obj.draw(ox, oy, 0, zoom, alpha, 0, 0, rz)
    end
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
