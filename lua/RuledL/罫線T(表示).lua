--label:tim2\罫線T.anm
---$track:線幅
---min=1
---max=500
---step=1
local track_line_width = 6

---$track:1行目高比
---min=0
---max=500
---step=0.1
local track_n_1_ratio = 100

---$track:1列目幅比
---min=0
---max=500
---step=0.1
local track_n_1_width_ratio = 100

---$track:背景透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$color:線色
local wcl = 0xffffff

---$check:座標保存
local SvC = 1

---$check:エッジ調整
local check0 = true

local RL = RuledlineT
local Lw = track_line_width
local balp = 1 - track_opacity * 0.01
local wcl = wcl or 0xffffff
local EGC = check0 and 1 or 0
local LPX = RL.LPX
local LPY = RL.LPY
local ACX = RL.ACX or {}
local ACY = RL.ACY or {}
local SLX = RL.SLX or {}
local SLY = RL.SLY or {}
local CX = RL.cx
local CY = RL.cy
local LwH = Lw * 0.5
local DrawSL = function(x0, y0, x1, y1, Lw, P)
    local MP = 1 - P
    local dx, dy = y1 - y0, x0 - x1
    local dr = math.sqrt(dx * dx + dy * dy)
    dx, dy = Lw * 0.5 * dx / dr, Lw * 0.5 * dy / dr
    local u0, v0, u1, v1, u2, v2, u3, v3 = x0 + dx, y0 + dy, x1 + dx, y1 + dy, x1 - dx, y1 - dy, x0 - dx, y0 - dy
    u0, u1 = P * u0 + MP * u1, MP * u0 + P * u1
    v0, v1 = P * v0 + MP * v1, MP * v0 + P * v1
    u2, u3 = P * u2 + MP * u3, MP * u2 + P * u3
    v2, v3 = P * v2 + MP * v3, MP * v2 + P * v3
    obj.drawpoly(u0, v0, 0, u1, v1, 0, u2, v2, 0, u3, v3, 0)
end
if RL.typ == 1 then
    hp = track_n_1_ratio
    wp = track_n_1_width_ratio
    local dw = RL.dw
    local dh = dw
    local nx = RL.nx
    local ny = RL.ny
    local asp = RL.asp
    if asp > 0 then
        dw = dw * (1 - asp)
    else
        dh = dh * (1 + asp)
    end
    wp = (RL.wp or wp or 100) * 0.01 * dw
    hp = (RL.hp or hp or 100) * 0.01 * dh
    dh, hp, wp = math.floor(dh), math.floor(hp), math.floor(wp)
    RL.Tw = wp + (nx - 1) * dw
    RL.Th = hp + (ny - 1) * dh
    RL.LPX[1] = -RL.Tw * 0.5
    for i = 2, nx + 1 do
        LPX[i] = wp + (i - 2) * dw - RL.Tw * 0.5
    end
    RL.LPY[1] = -RL.Th * 0.5
    for i = 2, ny + 1 do
        LPY[i] = hp + (i - 2) * dh - RL.Th * 0.5
    end
end
local ImW, ImH = RL.Tw + Lw, RL.Th + Lw
obj.copybuffer("cache:bk", "obj")
obj.setoption("drawtarget", "tempbuffer", ImW, ImH)
if #SLX > 0 then
    for m = 1, #SLX do
        obj.load("figure", "四角形", RL.Scl[m], 1)
        local Sdw = RL.Sdw[m]
        local Pdw = RL.Pdw[m]
        local SLC = RL.SLC[m]
        for k = 1, #SLX[m] do
            local x0 = SLX[m][k] - CX
            local y0 = SLY[m][k] - CY
            local Hx = -1
            local Hy = -1
            for s = 1, #LPX - 1 do
                if LPX[s] <= x0 and x0 < LPX[s + 1] then
                    Hx = s
                    break
                end
            end
            for s = 1, #LPY - 1 do
                if LPY[s] <= y0 and y0 < LPY[s + 1] then
                    Hy = s
                    break
                end
            end
            if Hx > 0 and Hy > 0 then
                x0 = LPX[Hx] + LwH
                y0 = LPY[Hy + 1] - LwH
                x1 = LPX[Hx + 1] - LwH
                y1 = LPY[Hy] + LwH
                if SLC == 0 or SLC == 2 then
                    DrawSL(x0, y0, x1, y1, Sdw, Pdw)
                end
                if SLC == 1 or SLC == 2 then
                    DrawSL(x0, y1, x1, y0, Sdw, Pdw)
                end
            end
        end
    end
end
obj.load("figure", "四角形", wcl, 1)
local delX = {}
local delY = {}
for i = 0, #LPX do
    delX[i] = {}
    delY[i] = {}
end
if #ACX > 0 then
    for m = 1, #ACX do
        for k = 1, #ACX[m] do
            ACX[m][k] = ACX[m][k] - CX
            ACY[m][k] = ACY[m][k] - CY
        end
    end
    for m = 1, #ACX do
        for k = 1, #RL.ACX[m] - 1 do
            local i0, i1, j0, j1 = 0, 0, 0, 0
            local x0 = ACX[m][k]
            local x1 = ACX[m][k + 1]
            local y0 = ACY[m][k]
            local y1 = ACY[m][k + 1]
            for s = 1, #LPX - 1 do
                if LPX[s] <= x0 and x0 < LPX[s + 1] then
                    i0 = s
                    break
                end
            end
            for s = 1, #LPX - 1 do
                if LPX[s] <= x1 and x1 < LPX[s + 1] then
                    i1 = s
                    break
                end
            end
            for s = 1, #LPY - 1 do
                if LPY[s] <= y0 and y0 < LPY[s + 1] then
                    j0 = s
                    break
                end
            end
            for s = 1, #LPY - 1 do
                if LPY[s] <= y1 and y1 < LPY[s + 1] then
                    j1 = s
                    break
                end
            end
            if LPX[#LPX] <= x0 then
                i0 = #LPX
            end
            if LPX[#LPX] <= x1 then
                i1 = #LPX
            end
            if LPY[#LPY] <= y0 then
                j0 = #LPY
            end
            if LPY[#LPY] <= y1 then
                j1 = #LPY
            end
            if i0 > i1 then
                i0, i1 = i1, i0
            end
            if j0 > j1 then
                j0, j1 = j1, j0
            end
            for i = i0, i1 do
                for j = j0, j1 - 1 do
                    if j1 > j0 then
                        delX[i][j + 1] = 1
                    end
                end
            end
            for j = j0, j1 do
                for i = i0, i1 - 1 do
                    if i1 > i0 then
                        delY[i + 1][j] = 1
                    end
                end
            end
        end
    end
end
for j = 1, #LPY do
    local y0 = LPY[j] - LwH
    local y1 = LPY[j] + LwH
    for i = 1, #LPX - 1 do
        local x0 = LPX[i] - LwH
        local x1 = LPX[i + 1] + LwH
        if delX[i][j] == nil then
            obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0)
        end
    end
end
for i = 1, #LPX do
    local x0 = LPX[i] - LwH
    local x1 = LPX[i] + LwH
    for j = 1, #LPY - 1 do
        local y0 = LPY[j] - LwH
        local y1 = LPY[j + 1] + LwH
        if delY[i][j] == nil then
            obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0)
        end
    end
end
obj.copybuffer("cache:img", "tmp")
obj.copybuffer("obj", "cache:bk")
obj.setoption("drawtarget", "tempbuffer", ImW, ImH)
obj.draw(-CX, -CY, 0, 1, balp)
obj.copybuffer("obj", "cache:img")
obj.draw()
obj.load("tempbuffer")
if RL.typ == 1 then
    CX = 0.5 * ((ImW - obj.screen_w) % 2) * EGC
    CY = 0.5 * ((ImH - obj.screen_h) % 2) * EGC
else
    CX = -CX + 0.5 * ((Lw - obj.screen_w) % 2) * EGC
    CY = -CY + 0.5 * ((Lw - obj.screen_h) % 2) * EGC
end
obj.cx, obj.cy = CX, CY
if SvC == 1 then
    RuledlineTcrd = {}
    RuledlineTcrd.X = LPX
    RuledlineTcrd.Y = LPY
    RuledlineTcrd.CX = -CX
    RuledlineTcrd.CY = -CY
end
RuledlineT = nil
RuledlineTASN = nil
