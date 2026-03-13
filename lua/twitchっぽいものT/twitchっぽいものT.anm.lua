--label:tim2\アニメーション効果
---$track:間隔ミリ秒
---min=1
---max=10000
---step=0.1
local track_interval_ms = 200

---$track:ズームブラー
---min=0
---max=200
---step=0.1
local track_zoom_blur = 100

---$track:スライドブラー
---min=0
---max=200
---step=0.1
local track_slide_blur = 100

---$track:色ずれ補正
---min=0
---max=200
---step=0.1
local track_color_offset_adjust = 100

---$track:ぼかし量
---min=0
---max=100
---step=0.1
local track_blur_amount = 5

---$track:ぼかし発生率％
---min=0
---max=100
---step=0.1
local track_blur_probability = 20

---$track:色量
---min=0
---max=100
---step=0.1
local track_color_amount = 5

---$track:色発生率％
---min=0
---max=100
---step=0.1
local track_color_probability = 20

---$track:明るさ量
---min=0
---max=100
---step=0.1
local track_light_amount = 20

---$track:明るさ発生率％
---min=0
---max=100
---step=0.1
local track_light_probability = 20

---$track:ズーム量
---min=0
---max=100
---step=0.1
local track_zoom_amount = 20

---$track:ズーム発生率％
---min=0
---max=100
---step=0.1
local track_zoom_probability = 20

---$track:スライド量
---min=0
---max=100
---step=0.1
local track_slide_amount = 10

---$track:スライド発生率％
---min=0
---max=100
---step=0.1
local track_slide_probability = 20

---$check:方向指定
local dirchk = 0

---$track:指定方向（度）
---min=-360
---max=360
---step=0.1
local track_direction_deg = 0

---$select:色ずれタイプ
---赤緑A=0
---赤青A=1
---緑青A=2
---赤緑B=3
---赤青B=4
---緑青B=5
local Cdir = 0

---$value:シード
local seed = 0

---$check:└レイヤー依存なし
local Lset = 1

local function clamp_percentage(value)
    if value < 0 then
        return 0
    elseif value > 100 then
        return 100
    end
    return value
end

local Cal = (function(LS)
    if LS == 0 then
        return function(time, p, rn1, rn2, seed)
            local tt = time * 1000 / track_interval_ms + 3103
            local tf, dt = math.modf(tt)
            local v = {}
            for i = 0, 3 do
                local ti = tf + i - 1
                if p > obj.rand(0, 100, ti, seed) then
                    local q = obj.rand(0, 100, ti + 1000, seed) * 0.01
                    v[i] = rn1 * q + rn2 * (1 - q)
                else
                    v[i] = 0
                end
            end
            return obj.interpolation(dt, v[0], v[1], v[2], v[3])
        end
    else
        return function(time, p, rn1, rn2, seed)
            local tt = time * 1000 / track_interval_ms + 3103
            local tf, dt = math.modf(tt)
            local v = {}
            for i = 0, 3 do
                local ti = tf + i
                if p > obj.rand(0, 100, -ti, seed) then
                    local q = obj.rand(0, 100, -ti, seed + 100) * 0.01
                    v[i] = rn1 * q + rn2 * (1 - q)
                else
                    v[i] = 0
                end
            end
            return obj.interpolation(dt, v[0], v[1], v[2], v[3])
        end
    end
end)(Lset or 0)
local blur_amount = clamp_percentage(track_blur_amount)
local blur_probability = clamp_percentage(track_blur_probability)
local color_amount = clamp_percentage(track_color_amount)
local color_probability = clamp_percentage(track_color_probability)
local light_amount = clamp_percentage(track_light_amount)
local light_probability = clamp_percentage(track_light_probability)
local zoom_amount = clamp_percentage(track_zoom_amount)
local zoom_probability = clamp_percentage(track_zoom_probability)
local slide_amount = clamp_percentage(track_slide_amount)
local slide_probability = clamp_percentage(track_slide_probability)

local bl = blur_amount
local cl = 360 * color_amount * 0.01
local li = light_amount
local zm = zoom_amount
local sl0 = slide_amount * 0.01
dirchk = dirchk or 0
local Drad = (track_direction_deg or 0) * math.pi / 180
Cdir = Cdir or 0
local w, h = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.setoption("blend", "alpha_add")
local t = obj.time
zm = zm * Cal(t, zoom_probability, 0, 1, seed)
local slx, sly
local cosDrad = math.cos(Drad)
local sinDrad = math.sin(Drad)
if dirchk == 1 then
    local r = w * sl0 * Cal(t, slide_probability, -1, 1, seed + 1000)
    slx = r * cosDrad
    sly = r * sinDrad
else
    slx = w * sl0 * Cal(t, slide_probability, -1, 1, seed + 1000)
    sly = h * sl0 * Cal(t, slide_probability, -1, 1, seed + 2000)
end
local slxZ, slyZ = slx, sly
slx = (slx + w * 0.5) % w - w * 0.5
sly = (sly + h * 0.5) % h - h * 0.5
local zmp = 1 + zm * 0.01
local dw = w * zmp
local dh = h * zmp
obj.draw(slx - dw, sly - dh, 0, zmp, 1, 0, 0, 180)
obj.draw(slx, sly - dh, 0, zmp, 1, 180, 0, 0)
obj.draw(slx + dw, sly - dh, 0, zmp, 1, 0, 0, 180)
obj.draw(slx - dw, sly, 0, zmp, 1, 0, 180, 0)
obj.draw(slx, sly, 0, zmp)
obj.draw(slx + dw, sly, 0, zmp, 1, 0, 180, 0)
obj.draw(slx - dw, sly + dh, 0, zmp, 1, 0, 0, 180)
obj.draw(slx, sly + dh, 0, zmp, 1, 180, 0, 0)
obj.draw(slx + dw, sly + dh, 0, zmp, 1, 0, 0, 180)
obj.load("tempbuffer")
obj.setoption("blend", 0)
bl = bl * Cal(t, blur_probability, 0, 1, seed + 3000)
cl = cl * Cal(t, color_probability, -1, 1, seed + 4000)
li = li * Cal(t, light_probability, 0, 1, seed + 5000)
obj.effect("ぼかし", "範囲", bl, "サイズ固定", 1)
obj.effect("色調補正", "明るさ", 100 + li, "色相", cl)
obj.effect(
    "放射ブラー",
    "範囲",
    zm * track_zoom_blur * 0.01,
    "X",
    -zmp * slxZ,
    "Y",
    -zmp * slyZ,
    "サイズ固定",
    1
)
local slx1, sly1, slx2, sly2
local dt = 0.5 / obj.framerate
if dirchk == 1 then
    local r = w * sl0 * Cal(t - dt, slide_probability, -1, 1, seed + 1000)
    slx1 = r * cosDrad
    sly1 = r * sinDrad
    r = w * sl0 * Cal(t + dt, slide_probability, -1, 1, seed + 1000)
    slx2 = r * cosDrad
    sly2 = r * sinDrad
else
    slx1 = w * sl0 * Cal(t - dt, slide_probability, -1, 1, seed + 1000)
    slx2 = w * sl0 * Cal(t + dt, slide_probability, -1, 1, seed + 1000)
    sly1 = h * sl0 * Cal(t - dt, slide_probability, -1, 1, seed + 2000)
    sly2 = h * sl0 * Cal(t + dt, slide_probability, -1, 1, seed + 2000)
end
local dx = slx2 - slx1
local dy = sly2 - sly1
local dr = math.sqrt(dx * dx + dy * dy)
local deg = math.atan2(-dx, dy) * 180 / math.pi
dr = dr * track_slide_blur * 0.01
local dc = dr * track_color_offset_adjust * 0.0025
obj.effect("方向ブラー", "角度", deg, "範囲", dr, "サイズ固定", 1)
obj.effect("領域拡張", "上", dc, "右", dc, "下", dc, "左", dc, "塗りつぶし", 1)
local dir_name_map = {
    [0] = "赤緑A",
    [1] = "赤青A",
    [2] = "緑青A",
    [3] = "赤緑B",
    [4] = "赤青B",
    [5] = "緑青B",
}
obj.effect("色ずれ", "ずれ幅", dc, "角度", deg, "色ずれの種類", dir_name_map[Cdir] or "赤緑A")
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.load("tempbuffer")
