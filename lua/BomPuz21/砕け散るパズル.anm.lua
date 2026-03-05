--label:tim2
---$track:展開
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 50

---$track:速度
---min=-5000
---max=5000
---step=0.1
local rename_me_track1 = 100

---$track:向き
---min=-180
---max=180
---step=0.1
local rename_me_track2 = 30

---$track:サイズ
---min=4
---max=1000
---step=1
local rename_me_track3 = 120

---$value:P形状[1〜22]
local Pfig = 1

---$check:読込画像表示
local LayAp = 0

---$check:配置ズレ
local Csht = 0

---$value:飛散中心
local Ct = { 0, 0 }

---$value:回転速度
local rv = 100

---$value:重力
local Gr = { 0, 100, 0 }

---$check:マップ画像読込
local loadmap = 0

---$value:MAP番号[1〜6]
local mapnum = 1

---$value:マップ角度
local mapdeg = 0

---$value:マップ中心
local Cmap = { 0, 0 }

---$value:マップ限界%
local limap = 500

---$value:隙間
local spt = 0

---$value:乱数シード
local seed = 0

---$check:表裏反転
local FBR = 0

---$check:マップ反転
local rename_me_check0 = true

Pfig = Pfig or 0
if Pfig == 0 then
    require("砕け散るパズル-old")
    OldScript(
        rename_me_track0,
        rename_me_track1,
        rename_me_track2,
        rename_me_track3,
        rename_me_check0,
        Ct,
        rv,
        Gr,
        loadmap,
        mapnum,
        limap,
        spt,
        seed
    )
else
    --ピース作成----------
    local Rotxy = function(x0, y0, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
        local m00 = cos_y * cos_z
        local m01 = -cos_y * sin_z
        local m10 = cos_x * sin_z + sin_x * sin_y * cos_z
        local m11 = cos_x * cos_z - sin_x * sin_y * sin_z
        local m20 = sin_x * sin_z - cos_x * sin_y * cos_z
        local m21 = sin_x * cos_z + cos_x * sin_y * sin_z
        return m00 * x0 + m01 * y0, m10 * x0 + m11 * y0, m20 * x0 + m21 * y0
    end
    local DrawUnitBase = function(SI2, ROT, ...)
        local arg = { ... }
        if arg[1] == 1 then
            obj.draw(0, -SI2, 0, 1, 1, 0, 0, ROT)
        end
        if arg[2] == 1 then
            obj.draw(SI2, 0, 0, 1, 1, 0, 0, 90 + ROT)
        end
        if arg[3] == 1 then
            obj.draw(0, SI2, 0, 1, 1, 0, 0, 180 + ROT)
        end
        if arg[4] == 1 then
            obj.draw(-SI2, 0, 0, 1, 1, 0, 0, 270 + ROT)
        end
    end
    local MakeUnitBase1 = function(SI, SI2, ...)
        local arg = { ... }
        obj.setoption("drawtarget", "tempbuffer", 2 * SI, 2 * SI)
        obj.load("figure", "四角形", 0xffffff, 1)
        obj.setoption("blend", "alpha_add")
        obj.drawpoly(-SI2, -SI2, 0, SI2, -SI2, 0, SI2, SI2, 0, -SI2, SI2, 0)
        obj.copybuffer("obj", "cache:Img1")
        obj.setoption("blend", "alpha_add")
        DrawUnitBase(SI2, 0, arg[1], arg[2], arg[3], arg[4])
        obj.setoption("blend", "alpha_sub")
        DrawUnitBase(SI2, 180, arg[5], arg[6], arg[7], arg[8])
    end
    local MakeUnitBase2 = function(SI, SI2, ...)
        local arg = { ... }
        MakeUnitBase1(SI, SI2, unpack(arg, 1, 8))
        obj.copybuffer("obj", "cache:Img2")
        obj.setoption("blend", "alpha_add")
        DrawUnitBase(SI2, 0, arg[9], arg[10], arg[11], arg[12])
        obj.setoption("blend", "alpha_sub")
        DrawUnitBase(SI2, 180, arg[13], arg[14], arg[15], arg[16])
    end
    local MakeUnit = function(SI, SI2, Pfig)
        if Pfig == 1 then
            MakeUnitBase2(SI, SI2, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0)
        elseif Pfig == 2 then
            MakeUnitBase2(SI, SI2, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0)
        elseif Pfig == 3 then
            MakeUnitBase2(SI, SI2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1)
        elseif Pfig == 4 then
            MakeUnitBase2(SI, SI2, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0)
        elseif Pfig == 9 or Pfig == 13 or Pfig == 18 then
            MakeUnitBase1(SI, SI2, 1, 0, 1, 0, 0, 1, 0, 1)
        elseif Pfig == 10 or Pfig == 14 or Pfig == 19 then
            MakeUnitBase1(SI, SI2, 1, 1, 0, 0, 0, 0, 1, 1)
        elseif Pfig == 11 or Pfig == 15 or Pfig == 20 then
            MakeUnitBase1(SI, SI2, 1, 1, 1, 1, 0, 0, 0, 0)
        elseif Pfig == 12 or Pfig == 16 or Pfig == 21 then
            MakeUnitBase1(SI, SI2, 1, 0, 0, 0, 0, 1, 1, 1)
        elseif Pfig == 17 or Pfig == 22 then
            MakeUnitBase1(SI, SI2, 1, 1, 1, 1, 1, 1, 1, 1)
        end
    end
    local MakeCachePC = function(SI, SI2, SID)
        obj.copybuffer("cache:PC1", "tmp")
        obj.copybuffer("cache:PC2", "tmp")
        obj.load("figure", "四角形", 0xffffff, SI * 2)
        obj.setoption("drawtarget", "tempbuffer", SID, SID)
        obj.setoption("blend", "alpha_add")
        obj.draw()
        obj.copybuffer("obj", "cache:PC1")
        obj.setoption("blend", "alpha_sub")
        if Pfig == 18 then
            obj.draw(0, 0, 0, 1.01)
        else
            obj.draw()
        end
        obj.copybuffer("cache:PC1", "tmp")
        if Pfig ~= 2 and Pfig ~= 6 and Pfig ~= 10 and Pfig ~= 14 and Pfig ~= 19 and Pfig ~= 17 and Pfig ~= 22 then
            obj.setoption("drawtarget", "tempbuffer", SID, SID)
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_add")
            obj.drawpoly(-SI2, -SI2, 0, SI2, -SI2, 0, SI2, SI2, 0, -SI2, SI2, 0)
            obj.drawpoly(0, -SI, 0, 0, -SI, 0, SI2, -SI2, 0, -SI2, -SI2, 0)
            obj.drawpoly(SI, 0, 0, SI, 0, 0, SI2, SI2, 0, SI2, -SI2, 0)
            obj.drawpoly(0, SI, 0, 0, SI, 0, -SI2, SI2, 0, SI2, SI2, 0)
            obj.drawpoly(-SI, 0, 0, -SI, 0, 0, -SI2, -SI2, 0, -SI2, SI2, 0)
            obj.copybuffer("obj", "cache:PC2")
            obj.setoption("blend", "alpha_sub")
            obj.draw(-SI, 0, 0)
            obj.draw(SI, 0, 0)
            obj.draw(0, -SI, 0)
            obj.draw(0, SI, 0)
            obj.copybuffer("cache:PC2", "tmp")
            obj.load("figure", "四角形", 0xffffff, SI * 2)
            obj.setoption("drawtarget", "tempbuffer", SID, SID)
            obj.setoption("blend", "alpha_add")
            obj.draw()
            obj.copybuffer("obj", "cache:PC2")
            obj.setoption("blend", "alpha_sub")
            obj.draw()
        end
        obj.copybuffer("cache:PC2", "tmp")
    end
    local MakeSpl = function(SI, spt, Pfig)
        local SI = SI
        local SI2 = SI / 2
        local SI4 = SI / 4
        local SID = 2 * SI + SI % 2 -- 四隅に隙間ができることがあるのを防止
        local comSI2 = 2 * math.floor((SI2 + 1) / 2) -- 余分な線が入るのを防止
        if Pfig < 0 then --レイヤー読み込み
            obj.copybuffer("tmp", "cache:LayImg")
        elseif Pfig >= 1 and Pfig <= 4 then
            obj.setoption("drawtarget", "tempbuffer", SI, SI)
            local se = 2
            local bai = SI / 200
            obj.load("figure", "円", 0xffffff, 78 * bai * se)
            obj.setoption("blend", "alpha_add")
            x0 = -39 * bai
            y0 = (-138 - 39 * 0.79 + 100) * bai
            y2 = (-138 + 39 * 0.79 + 100 + 2) * bai
            obj.drawpoly(x0, y0, 0, -x0, y0, 0, -x0, y2, 0, x0, y2, 0)
            DS = (2857 - 21 * math.sqrt(18119)) / 4640
            x4, y4 = 32.5445 * bai, (121.0223 + 0.4) * bai - 100 * bai
            x5, y5 = 23.9438 * bai, 110.7341 * bai - 100 * bai
            x6, y6 = (32 + DS) * bai, (104 - math.sqrt(21 * 21 / 4 - DS * DS)) * bai - 100 * bai
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_add")
            obj.drawpoly(-x4, -y4, 0, x4, -y4, 0, x5, -y5, 0, -x5, -y5, 0)
            obj.drawpoly(-x5, -y5, 0, x5, -y5, 0, x6, -y6, 0, -x6, -y6, 0)
            obj.drawpoly(-x6, -y6, 0, x6, -y6, 0, x6, SI / 2, 0, -x6, SI / 2, 0)
            obj.drawpoly(x6, -y6, 0, SI2, 0, 0, SI2, SI2, 0, x6, SI2, 0)
            obj.drawpoly(-x6, -y6, 0, -SI2, 0, 0, -SI2, SI2, 0, -x6, SI2, 0)
            obj.load("figure", "円", 0xffffff, 21 * bai * se)
            obj.setoption("blend", "alpha_sub")
            obj.draw(32 * bai, -104 * bai + 100 * bai, 0, 1 / se)
            obj.draw(-32 * bai, -104 * bai + 100 * bai, 0, 1 / se)
            obj.copybuffer("cache:Img2", "tmp")
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_sub")
            obj.drawpoly(-SI2, 0, 0, SI2, 0, 0, SI2, SI2, 0, -SI2, SI2, 0)
            obj.copybuffer("cache:Img1", "tmp")
            obj.copybuffer("tmp", "cache:Img2")
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_add")
            obj.drawpoly(-SI2, 0, 0, SI2, 0, 0, SI2, -SI2, 0, -SI2, -SI2, 0)
            obj.copybuffer("obj", "tmp")
            obj.effect("反転", "透明度反転", 1)
            obj.effect("ローテーション", "90度回転", 2)
            obj.copybuffer("cache:Img2", "obj")
            MakeUnit(SI, SI2, Pfig)
        elseif Pfig >= 5 and Pfig <= 8 then
            local L = math.sqrt(2) * SI + 1
            obj.setoption("drawtarget", "tempbuffer", SID, SID)
            obj.load("figure", "円", 0xffffff, 3 * L)
            obj.setoption("blend", "alpha_add")
            obj.draw(0, 0, 0, 1 / 3)
            obj.copybuffer("obj", "tmp")
            obj.setoption("blend", "alpha_sub")
            if Pfig == 5 then
                obj.draw(-SI - 1, 0, 0) --ゴミ対策で±1
                obj.draw(SI + 1, 0, 0)
            elseif Pfig == 6 then
                obj.draw(0, SI + 1, 0)
                obj.draw(-SI - 1, 0, 0)
            elseif Pfig == 8 then
                obj.draw(0, SI + 1, 0)
            end
        elseif Pfig >= 9 and Pfig <= 22 then
            local x0, x1, x2, x3
            local y0, y1, y2, y3
            if Pfig >= 9 and Pfig <= 12 then
                x0, y0, x1, y1, x2, y2, x3, y3 =
                    -SI2 * 0.44, -SI2 * 0.25, SI2 * 0.44, -SI2 * 0.25, SI2 * 0.3, 0, -SI2 * 0.3, 0
            elseif Pfig >= 13 and Pfig <= 17 then
                local dH = SI / 5
                x0, y0, x1, y1, x2, y2, x3, y3 =
                    -SI2 + dH, -0.6 * dH, -SI2 + 2 * dH, -0.6 * dH, -SI2 + 2 * dH, 0, -SI2 + dH, 0
            elseif Pfig >= 18 and Pfig <= 22 then
                local dH = SI / 7
                x0, y0, x1, y1, x2, y2, x3, y3 =
                    -SI2 + 2 * dH, -1.2 * dH, -SI2 + 2 * dH, -1.2 * dH, -SI2 + 3 * dH, 0, -SI2 + dH, 0
            end
            obj.setoption("drawtarget", "tempbuffer", SI, comSI2)
            obj.load("figure", "四角形", 0xffffff, 1)
            obj.setoption("blend", "alpha_add")
            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
            if (Pfig >= 13 and Pfig <= 16) or (Pfig >= 18 and Pfig <= 21) then
                obj.drawpoly(-x0, y0, 0, -x1, y1, 0, -x2, y2, 0, -x3, y3, 0)
            end
            obj.copybuffer("cache:Img1", "tmp")
            MakeUnit(SI, SI2, Pfig)
        end
        MakeCachePC(SI, SI2, SID)
        if spt > 0 then
            for i = 1, 2 do
                obj.copybuffer("obj", "cache:PC" .. i)
                obj.effect("縁取り", "サイズ", spt, "ぼかし", 0)
                obj.setoption("drawtarget", "tempbuffer", SID, SID)
                obj.setoption("blend", 0)
                obj.draw()
                obj.copybuffer("cache:PC" .. i, "tmp")
            end
        end
    end
    --時間（マップ）作成----------
    local MakeMap = function(SI, mapnum, mapdeg, nx, ny, nxd, nyd, Cmap, loadmap, check0, apt, limap)
        local T = {}
        if loadmap == 0 then
            local Tcal = ({
                function(ii, jj, RR, seed)
                    return math.sqrt(ii * ii + jj * jj) / RR
                end, --1.円
                function(ii, jj, RR, seed)
                    return math.max(math.abs(ii), math.abs(jj)) / RR
                end, --2.四角
                function(ii, jj, RR, seed)
                    return math.min(math.abs(ii), math.abs(jj)) / RR
                end, --3.十字
                function(ii, jj, RR, seed)
                    return math.abs(jj) / RR
                end, --4.中央直線
                function(ii, jj, RR, seed)
                    return (math.pi - math.atan2(ii, jj)) / RR
                end, --5.時計
                function(ii, jj, RR, seed)
                    return obj.rand(0, RR, -(RR + ii + seed), RR + jj + 1000) / RR
                end, --6.ランダム
            })[mapnum]
            local RR = ({
                math.sqrt(nxd * nxd + nyd * nyd),
                math.max(nxd, nyd),
                math.min(nxd, nyd),
                ny,
                math.pi * 2,
                (2 * nxd + 1) * (2 * nyd + 1),
            })[mapnum]
            local Cnx, Cny = Cmap[1] / SI, Cmap[2] / SI
            local sin, cos = math.sin(mapdeg), math.cos(mapdeg)
            for i = -nx, nx do
                T[i] = {}
                local iCnx = i - Cnx
                for j = -ny, ny do
                    local ii, jj = iCnx * cos + (j - Cny) * sin, -iCnx * sin + (j - Cny) * cos
                    T[i][j] = Tcal(ii, jj, RR, seed)
                end
            end
        else
            obj.load("layer", mapnum, true)
            local w, h = obj.getpixel()
            obj.pixeloption("type", "yc")
            obj.pixeloption("get", "obj")
            for i = -nx, nx do
                T[i] = {}
                for j = -ny, ny do
                    local yi, cbi, cri, ai =
                        obj.getpixel((w - 1) * (i + nx) / (2 * nx), (h - 1) * (j + ny) / (2 * ny), "yc")
                    T[i][j] = yi / 4096
                end
            end
        end
        if check0 then
            local Tmax = -100000
            for i = -nx, nx do
                for j = -ny, ny do
                    Tmax = Tmax > T[i][j] and Tmax or T[i][j]
                end
            end
            for i = -nx, nx do
                for j = -ny, ny do
                    T[i][j] = Tmax - T[i][j]
                end
            end
        end
        for i = -nx, nx do
            for j = -ny, ny do
                local t
                if T[i][j] <= limap then
                    t = -T[i][j] + apt
                    T[i][j] = math.max(t, 0)
                else
                    T[i][j] = 0
                end
            end
        end
        return T
    end
    --メイン----------
    local zoom = obj.getvalue("zoom") * 0.01
    local apt = rename_me_track0 * 0.01
    local Vs = rename_me_track1 * 7.5
    local dir = -math.rad(rename_me_track2)
    Csht = Csht or 0
    LayAp = LayAp or 0
    Cmap = Cmap or { 0, 0 }
    mapdeg = (mapdeg or 0) * math.pi / 180
    FBR = FBR or 0
    obj.setanchor("Cmap", #Cmap / 2, "line")
    obj.setanchor("Ct", 1)
    if #Cmap > 3 then
        mapdeg = -math.atan2(Cmap[3] - Cmap[1], Cmap[4] - Cmap[2])
    end
    rv = rv * 0.03
    Gr[1] = Gr[1] * 30 * zoom
    Gr[2] = Gr[2] * 30 * zoom
    Gr[3] = Gr[3] * 30 * zoom
    limap = limap * 0.01
    local SI = math.floor(rename_me_track3)
    local w, h = obj.getpixel()
    local nxd = (w - SI) / SI * 0.5
    local nyd = (h - SI) / SI * 0.5
    local nx = math.floor(w / SI * 0.5 + 1)
    local ny = math.floor(h / SI * 0.5 + 1)
    local w2, h2 = w * 0.5, h * 0.5
    local SIz = SI * zoom
    local wz = w * zoom
    local hz = h * zoom
    local wz2 = wz / 2
    local hz2 = hz / 2
    Vs = Vs * zoom
    Ct[1] = Ct[1] / SI
    Ct[2] = Ct[2] / SI
    if Pfig < 0 then --レイヤー読み込み
        obj.copybuffer("cache:ORI", "obj")
        obj.setoption("drawtarget", "tempbuffer", SI * 2 + SI % 2, SI * 2 + SI % 2)
        obj.load("layer", -Pfig, true)
        obj.drawpoly(-SI, -SI, 0, SI, -SI, 0, SI, SI, 0, -SI, SI, 0)
        obj.copybuffer("cache:LayImg", "tmp")
        if LayAp == 1 then
            obj.copybuffer("obj", "tmp")
            obj.copybuffer("tmp", "cache:ORI")
            local di = ((nx + ny) % 2 == Csht) and 1 or 0
            for j = -ny, ny do
                di = 1 - di
                for i = -nx + di, nx, 2 do
                    obj.draw(SI * i, SI * j)
                end
            end
            obj.copybuffer("cache:ORI", "tmp")
        end
    else
        obj.copybuffer("cache:ORI", "obj")
    end
    --ピース作成
    MakeSpl(SI, spt, Pfig)
    --時間（マップ）作成
    local T = MakeMap(SI, mapnum, mapdeg, nx, ny, nxd, nyd, Cmap, loadmap, rename_me_check0, apt, limap)
    --表示
    obj.setoption("drawtarget", "tempbuffer")
    DrawPoly = ({
        function(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, u0, v0, u1, v1, u2, v2, u3, v3)
            obj.drawpoly(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, u0, v0, u1, v1, u2, v2, u3, v3)
        end,
        function(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, u0, v0, u1, v1, u2, v2, u3, v3)
            obj.drawpoly(x3, y3, z3, x2, y2, z2, x1, y1, z1, x0, y0, z0, u3, v3, u2, v2, u1, v1, u0, v0)
        end,
    })[FBR + 1]
    local sht = ((nx + ny) % 2 == Csht) and 0 or 1
    for dj = 0, 1 do
        for di = 0, 1 do
            obj.copybuffer("tmp", "cache:ORI")
            obj.setoption("drawtarget", "tempbuffer")
            if (di + dj) % 2 == sht then
                obj.copybuffer("obj", "cache:PC1")
            else
                obj.copybuffer("obj", "cache:PC2")
            end
            obj.setoption("blend", "alpha_sub")
            for j = -ny + dj, ny, 2 do
                for i = -nx + di, nx, 2 do
                    obj.draw(i * SI, j * SI, 0)
                end
            end
            obj.copybuffer("obj", "tmp")
            obj.setoption("drawtarget", "framebuffer")
            obj.setoption("blend", 0)
            for j = -ny + dj, ny, 2 do
                local yy = SIz * j
                for i = -nx + di, nx, 2 do
                    local t = T[i][j]
                    local xx = SIz * i
                    local x0, x1, x2, x3 = xx - SIz, xx + SIz, xx + SIz, xx - SIz
                    local y0, y1, y2, y3 = yy - SIz, yy - SIz, yy + SIz, yy + SIz
                    local z0, z1, z2, z3
                    x0 = x0 < -wz2 and -wz2 or (x0 > wz2 and wz2 or x0)
                    x1 = x1 < -wz2 and -wz2 or (x1 > wz2 and wz2 or x1)
                    x2 = x2 < -wz2 and -wz2 or (x2 > wz2 and wz2 or x2)
                    x3 = x3 < -wz2 and -wz2 or (x3 > wz2 and wz2 or x3)
                    y0 = y0 < -hz2 and -hz2 or (y0 > hz2 and hz2 or y0)
                    y1 = y1 < -hz2 and -hz2 or (y1 > hz2 and hz2 or y1)
                    y2 = y2 < -hz2 and -hz2 or (y2 > hz2 and hz2 or y2)
                    y3 = y3 < -hz2 and -hz2 or (y3 > hz2 and hz2 or y3)
                    local u0, u1, u2, u3 = x0 + wz2, x1 + wz2, x2 + wz2, x3 + wz2
                    local v0, v1, v2, v3 = y0 + hz2, y1 + hz2, y2 + hz2, y3 + hz2
                    local r1 = obj.rand(-100, 100, -(i + nx + j + ny + seed), 2000) * 0.01 * t * rv
                    local r2 = obj.rand(-100, 100, -(i + nx + j + ny + seed), 3000) * 0.01 * t * rv
                    local r3 = obj.rand(-100, 100, -(i + nx + j + ny + seed), 4000) * 0.01 * t * rv
                    local sin_x = math.sin(r1)
                    local cos_x = math.cos(r1)
                    local sin_y = math.sin(r2)
                    local cos_y = math.cos(r2)
                    local sin_z = math.sin(r3)
                    local cos_z = math.cos(r3)
                    local dx = (x0 + x1 + x2 + x3) / 4
                    local dy = (y0 + y1 + y2 + y3) / 4
                    x0, y0, z0 = Rotxy(x0 - dx, y0 - dy, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                    x1, y1, z1 = Rotxy(x1 - dx, y1 - dy, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                    x2, y2, z2 = Rotxy(x2 - dx, y2 - dy, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                    x3, y3, z3 = Rotxy(x3 - dx, y3 - dy, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                    x0, x1, x2, x3 = x0 + dx, x1 + dx, x2 + dx, x3 + dx
                    y0, y1, y2, y3 = y0 + dy, y1 + dy, y2 + dy, y3 + dy
                    local ii = i - Ct[1]
                    local jj = j - Ct[2]
                    local rads = dir * math.sqrt(ii * ii + jj * jj) / ny
                    local vg1 = -Vs * math.sin(rads)
                    local Vz = -Vs * math.cos(rads)
                    rads = math.atan2(ii, jj)
                    local Vx = vg1 * math.sin(rads)
                    local Vy = vg1 * math.cos(rads)
                    local itix = Gr[1] * t * t * 0.5 + Vx * t
                    local itiy = Gr[2] * t * t * 0.5 + Vy * t
                    local itiz = Gr[3] * t * t * 0.5 + Vz * t
                    x0, x1, x2, x3 = x0 + itix, x1 + itix, x2 + itix, x3 + itix
                    y0, y1, y2, y3 = y0 + itiy, y1 + itiy, y2 + itiy, y3 + itiy
                    z0, z1, z2, z3 = z0 + itiz, z1 + itiz, z2 + itiz, z3 + itiz
                    DrawPoly(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, u0, v0, u1, v1, u2, v2, u3, v3)
                end
            end
        end
    end
    obj.setoption("blend", 0)
end
