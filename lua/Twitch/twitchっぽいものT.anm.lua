--label:tim2
---$track:間隔ﾐﾘ秒
---min=1
---max=10000
---step=0.1
local rename_me_track0 = 200

---$track:ｽﾞｰﾑﾌﾞﾗｰ
---min=0
---max=200
---step=0.1
local rename_me_track1 = 100

---$track:ｽﾗｲﾄﾞﾌﾞﾗｰ
---min=0
---max=200
---step=0.1
local rename_me_track2 = 100

---$track:色ｽﾞﾚ補正
---min=0
---max=200
---step=0.1
local rename_me_track3 = 100

---$value:ぼかし{量，%}
local blur = { 5, 20 }

---$value:色{量，%}
local color = { 5, 20 }

---$value:明るさ{量，%}
local light = { 20, 20 }

---$value:ズーム{量，%}
local zoom = { 20, 20 }

---$value:スライド{量，%}
local slide = { 10, 20 }

---$check:方向指定
local dirchk = 0

---$value:指定方向(度)
local Drad = 0

---$value:色ずれタイプ[0-5]
local Cdir = 0

---$value:シード
local seed = 0

---$check:└ﾚｲﾔｰ依存なし
local Lset = 1

local Cal = (function(LS)
    if LS == 0 then
        return function(time, p, rn1, rn2, seed)
            local tt = time * 1000 / rename_me_track0 + 3103
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
            local tt = time * 1000 / rename_me_track0 + 3103
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
for i = 1, 2 do
    if blur[i] < 0 then
        blur[i] = 0
    elseif blur[i] > 100 then
        blur[i] = 100
    end
    if color[i] < 0 then
        color[i] = 0
    elseif color[i] > 100 then
        color[i] = 100
    end
    if light[i] < 0 then
        light[i] = 0
    elseif light[i] > 100 then
        light[i] = 100
    end
    if zoom[i] < 0 then
        zoom[i] = 0
    elseif zoom[i] > 100 then
        zoom[i] = 100
    end
    if slide[i] < 0 then
        slide[i] = 0
    elseif slide[i] > 100 then
        slide[i] = 100
    end
end
local bl = blur[1]
local cl = 360 * color[1] * 0.01
local li = light[1]
local zm = zoom[1]
local sl0 = slide[1] * 0.01
dirchk = dirchk or 0
Drad = (Drad or 0) * math.pi / 180
Cdir = Cdir or 0
local w, h = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.setoption("blend", "alpha_add")
local t = obj.time
zm = zm * Cal(t, zoom[2], 0, 1, seed)
local slx, sly
local cosDrad = math.cos(Drad)
local sinDrad = math.sin(Drad)
if dirchk == 1 then
    local r = w * sl0 * Cal(t, slide[2], -1, 1, seed + 1000)
    slx = r * cosDrad
    sly = r * sinDrad
else
    slx = w * sl0 * Cal(t, slide[2], -1, 1, seed + 1000)
    sly = h * sl0 * Cal(t, slide[2], -1, 1, seed + 2000)
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
bl = bl * Cal(t, blur[2], 0, 1, seed + 3000)
cl = cl * Cal(t, color[2], -1, 1, seed + 4000)
li = li * Cal(t, light[2], 0, 1, seed + 5000)
obj.effect("ぼかし", "範囲", bl, "サイズ固定", 1)
obj.effect("色調補正", "明るさ", 100 + li, "色相", cl)
obj.effect(
    "放射ブラー",
    "範囲",
    zm * rename_me_track1 * 0.01,
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
    local r = w * sl0 * Cal(t - dt, slide[2], -1, 1, seed + 1000)
    slx1 = r * cosDrad
    sly1 = r * sinDrad
    r = w * sl0 * Cal(t + dt, slide[2], -1, 1, seed + 1000)
    slx2 = r * cosDrad
    sly2 = r * sinDrad
else
    slx1 = w * sl0 * Cal(t - dt, slide[2], -1, 1, seed + 1000)
    slx2 = w * sl0 * Cal(t + dt, slide[2], -1, 1, seed + 1000)
    sly1 = h * sl0 * Cal(t - dt, slide[2], -1, 1, seed + 2000)
    sly2 = h * sl0 * Cal(t + dt, slide[2], -1, 1, seed + 2000)
end
local dx = slx2 - slx1
local dy = sly2 - sly1
local dr = math.sqrt(dx * dx + dy * dy)
local deg = math.atan2(-dx, dy) * 180 / math.pi
dr = dr * rename_me_track2 * 0.01
local dc = dr * rename_me_track3 * 0.0025
obj.effect("方向ブラー", "角度", deg, "範囲", dr, "サイズ固定", 1)
obj.effect("領域拡張", "上", dc, "右", dc, "下", dc, "左", dc, "塗りつぶし", 1)
obj.effect("色ずれ", "ずれ幅", dc, "角度", deg, "type", Cdir)
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.load("tempbuffer")
