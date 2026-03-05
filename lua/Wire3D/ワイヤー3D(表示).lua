--label:tim2\ワイヤー3D.anm
---$track:横サイズ
---min=0
---max=10000
---step=0.1
local rename_me_track0 = 500

---$track:縦サイズ
---min=0
---max=10000
---step=0.1
local rename_me_track1 = 500

---$track:高さ
---min=-5000
---max=5000
---step=0.1
local rename_me_track2 = 150

---$track:高さ基準
---min=0
---max=100
---step=0.01
local rename_me_track3 = 0

---$color:線色
local color = 0xffffff

---$check:塗り
local BR = 0

---$color:塗色
local colorF = 0x0000ff

---$check:アンチエイリアス
local ant = 1

---$check:高精度(線のみ)
local PC = 0

---$value:高精度間隔
local Pst = 2

---$figure:高精度形状
local fig = "円"

---$check:高精度自動向き
local adi = 1

---$value:縦横幅
local cc = { 10, 10, 2 }

---$check:YZ反転
local rename_me_check0 = true

if WireT_c_nw == nil then
    WireT_c_nw = cc[1] or 10
    WireT_c_nh = cc[2] or 10
    WireT_line = cc[3] or 2
    local w, h = obj.getpixel()
    obj.pixeloption("type", "yc")
    obj.pixeloption("get", "obj")
    WireT_data = {}
    for i = 0, WireT_c_nw do
        WireT_data[i] = {}
        for j = 0, WireT_c_nh do
            local yi, cbi, cri, ai = obj.getpixel((w - 1) * i / WireT_c_nw, (h - 1) * j / WireT_c_nh, "yc")
            WireT_data[i][j] = yi / 4096
        end
    end
end

local c_w = rename_me_track0
local c_h = rename_me_track1
local c_d = -rename_me_track2
local c_bp = rename_me_track3 * 0.01

local c_nw = WireT_c_nw
local c_nh = WireT_c_nh
local line = WireT_line
local data = WireT_data

local ox, oy, oz = obj.ox, obj.oy, obj.oz
ox = ox - c_w * 0.5
oz = oz + c_h * 0.5
local pw = c_w / c_nw
local ph = c_h / c_nh
local hpw = pw * 0.5
local hph = ph * 0.5

Pst = Pst or 2
if Pst < 0.5 then
    Pst = 0.5
end

for i = 0, c_nw do
    for j = 0, c_nh do
        data[i][j] = c_d * (data[i][j] - c_bp) + oy
    end
end

obj.setoption("antialias", ant)
obj.setoption("focus_mode", "fixed_size")

if PC == 0 then
    local o_drawpoly

    if BR == 0 then
        obj.load("figure", "四角形", color, math.max(pw, ph), line)
        if rename_me_check0 then
            o_drawpoly = function(cx, x0, x1, y0, y1, y2, y3, cz, hph)
                local z0 = cz + hph
                local z1 = cz - hph
                obj.drawpoly(x0, y0, z0, x1, y1, z0, x1, y2, z1, x0, y3, z1)
            end
        else
            o_drawpoly = function(cx, x0, x1, y0, y1, y2, y3, cz, hph)
                local z0 = cz + hph
                local z1 = cz - hph
                obj.drawpoly(x0, -z0, y0, x1, -z0, y1, x1, -z1, y2, x0, -z1, y3)
            end
        end
    else
        local fs = math.max(pw, ph)
        obj.load("figure", "四角形", colorF, fs)
        obj.copybuffer("tmp", "obj")
        obj.setoption("drawtarget", "tempbuffer")
        obj.load("figure", "四角形", color, fs, line)
        obj.draw()
        obj.load("tempbuffer")
        obj.setoption("drawtarget", "framebuffer")

        if rename_me_check0 then
            o_drawpoly = function(cx, x0, x1, y0, y1, y2, y3, cz, hph)
                local cy = (y0 + y1 + y2 + y3) * 0.25
                local z0 = cz + hph
                local z1 = cz - hph
                local w, w2, h2 = obj.w, obj.w * 0.5, obj.h * 0.5
                obj.drawpoly(cx, cy, cz, cx, cy, cz, x0, y0, z0, x1, y1, z0, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cy, cz, cx, cy, cz, x1, y1, z0, x1, y2, z1, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cy, cz, cx, cy, cz, x1, y2, z1, x0, y3, z1, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cy, cz, cx, cy, cz, x0, y3, z1, x0, y0, z0, w2, h2, w2, h2, 0, 0, w, 0)
            end
        else
            o_drawpoly = function(cx, x0, x1, y0, y1, y2, y3, cz, hph)
                local cy = (y0 + y1 + y2 + y3) * 0.25
                cz = -cz
                local z0 = cz - hph
                local z1 = cz + hph
                local w, w2, h2 = obj.w, obj.w * 0.5, obj.h * 0.5
                obj.drawpoly(cx, cz, cy, cx, cz, cy, x0, z0, y0, x1, z0, y1, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cz, cy, cx, cz, cy, x1, z0, y1, x1, z1, y2, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cz, cy, cx, cz, cy, x1, z1, y2, x0, z1, y3, w2, h2, w2, h2, 0, 0, w, 0)
                obj.drawpoly(cx, cz, cy, cx, cz, cy, x0, z1, y3, x0, z0, y0, w2, h2, w2, h2, 0, 0, w, 0)
            end
        end
    end

    for i = 0, c_nw - 1 do
        local x = ox + pw * (0.5 + i)
        local x0, x1 = x - hpw, x + hpw
        for j = 0, c_nh - 1 do
            local z = oz - ph * (0.5 + j)
            local y0, y1, y2, y3 = data[i][j], data[i + 1][j], data[i + 1][j + 1], data[i][j + 1]

            o_drawpoly(x, x0, x1, y0, y1, y2, y3, z, hph)
        end
    end
else
    local setCx, setCz
    if rename_me_check0 then
        setCx = function(x, y0, y1, z0, dz, Pst)
            local dy = y1 - y0
            local r = math.sqrt(dy * dy + dz * dz)
            local N = math.floor(r / Pst)
            for i = 1, N - 1 do
                local rt = i / N
                obj.draw(x, y0 + dy * rt, z0 + dz * rt)
            end
        end
        setCz = function(x0, dx, y0, y1, z, Pst)
            local dy = y1 - y0
            local r = math.sqrt(dx * dx + dy * dy)
            local N = math.floor(r / Pst)
            for i = 1, N - 1 do
                local rt = i / N
                obj.draw(x0 + dx * rt, y0 + dy * rt, z)
            end
        end
    else
        setCx = function(x, y0, y1, z0, dz, Pst)
            local dy = y1 - y0
            local r = math.sqrt(dy * dy + dz * dz)
            local N = math.floor(r / Pst)
            for i = 1, N - 1 do
                local rt = i / N
                obj.draw(x, -z0 - dz * rt, y0 + dy * rt)
            end
        end
        setCz = function(x0, dx, y0, y1, z, Pst)
            local dy = y1 - y0
            local r = math.sqrt(dx * dx + dy * dy)
            local N = math.floor(r / Pst)
            for i = 1, N - 1 do
                local rt = i / N
                obj.draw(x0 + dx * rt, -z, y0 + dy * rt)
            end
        end
    end

    obj.load("figure", fig, color, line * 2)
    if adi == 1 then
        obj.setoption("billboard", 3)
    end

    local x = {}
    local z = {}
    for i = 0, c_nw do
        x[i] = ox + pw * i
    end
    for j = 0, c_nh do
        z[j] = oz - ph * j
    end

    for i = 0, c_nw - 1 do
        for j = 0, c_nh do
            setCz(x[i], pw, data[i][j], data[i + 1][j], z[j], Pst)
        end
    end

    for i = 0, c_nw do
        for j = 0, c_nh - 1 do
            setCx(x[i], data[i][j], data[i][j + 1], z[j], -ph, Pst)
        end
    end

    if rename_me_check0 then
        for i = 0, c_nw do
            for j = 0, c_nh do
                obj.draw(x[i], data[i][j], z[j])
            end
        end
    else
        for i = 0, c_nw do
            for j = 0, c_nh do
                obj.draw(x[i], -z[j], data[i][j])
            end
        end
    end
end

WireT_c_nw = nil
WireT_c_nh = nil
WireT_line = nil
WireT_data = nil
