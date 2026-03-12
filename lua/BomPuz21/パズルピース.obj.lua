--label:tim2\カスタムオブジェクト
---$track:サイズ
---min=4
---max=1000
---step=1
local track_size = 120

---$track:P形状
---min=1
---max=22
---step=1
local track_p = 1

---$track:凹凸
---min=1
---max=2
---step=1
local track_bump = 1

---$color:色
local color = 0xffffff

local Pfig = track_p
local SI = math.floor(track_size)

-- NOTE: AviUtl2 beta36a現在、alpha_subで描画した部分のアルファ値がマイナスになると描画がおかしくなるので、u8の範囲で飽和させてから描画するようにする
local function fix_alpha_sub_workaround(target)
    obj.putpixeldata(target, obj.getpixeldata(target))
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

local SI2 = SI / 2
local SI4 = SI / 4
local SID = 2 * SI + SI % 2                  -- 四隅に隙間ができることがあるのを防止
local comSI2 = 2 * math.floor((SI2 + 1) / 2) -- 余分な線が入るのを防止

if Pfig >= 1 and Pfig <= 4 then
    obj.setoption("drawtarget", "tempbuffer", SI, SI)
    local se = 2
    local bai = SI / 200
    obj.load("figure", "円", 0xffffff, 78 * bai * se)
    obj.setoption("blend", "none")
    x0 = -39 * bai
    y0 = (-138 - 39 * 0.79 + 100) * bai
    y2 = (-138 + 39 * 0.79 + 100 + 2) * bai
    obj.drawpoly(x0, y0, 0, -x0, y0, 0, -x0, y2, 0, x0, y2, 0)

    DS = (2857 - 21 * math.sqrt(18119)) / 4640

    x4, y4 = 32.5445 * bai, (121.0223 + 0.4) * bai - 100 * bai
    x5, y5 = 23.9438 * bai, 110.7341 * bai - 100 * bai
    x6, y6 = (32 + DS) * bai, (104 - math.sqrt(21 * 21 / 4 - DS * DS)) * bai - 100 * bai

    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "none")
    obj.drawpoly(-x4, -y4, 0, x4, -y4, 0, x5, -y5, 0, -x5, -y5, 0)
    obj.drawpoly(-x5, -y5, 0, x5, -y5, 0, x6, -y6, 0, -x6, -y6, 0)

    obj.drawpoly(-x6, -y6, 0, x6, -y6, 0, x6, SI / 2, 0, -x6, SI / 2, 0)

    obj.drawpoly(x6, -y6, 0, SI2, 0, 0, SI2, SI2, 0, x6, SI2, 0)
    obj.drawpoly(-x6, -y6, 0, -SI2, 0, 0, -SI2, SI2, 0, -x6, SI2, 0)

    obj.load("figure", "円", 0xffffff, 21 * bai * se)
    obj.setoption("blend", "alpha_sub")
    obj.draw(32 * bai, -104 * bai + 100 * bai, 0, 1 / se)
    obj.draw(-32 * bai, -104 * bai + 100 * bai, 0, 1 / se)

    fix_alpha_sub_workaround("tempbuffer")

    obj.copybuffer("cache:Img2", "tempbuffer")

    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "alpha_sub")
    obj.drawpoly(-SI2, 0, 0, SI2, 0, 0, SI2, SI2, 0, -SI2, SI2, 0)

    fix_alpha_sub_workaround("tempbuffer")

    obj.copybuffer("cache:Img1", "tempbuffer")

    obj.copybuffer("tempbuffer", "cache:Img2")
    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "alpha_add")
    obj.drawpoly(-SI2, 0, 0, SI2, 0, 0, SI2, -SI2, 0, -SI2, -SI2, 0)

    obj.copybuffer("object", "tempbuffer")
    obj.effect("反転", "透明度反転", 1)
    obj.effect("ローテーション", "90度回転", 2)
    obj.copybuffer("cache:Img2", "object")

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
        x0, y0, x1, y1, x2, y2, x3, y3 = -SI2 * 0.44, -SI2 * 0.25, SI2 * 0.44, -SI2 * 0.25, SI2 * 0.3, 0, -SI2 * 0.3, 0
    elseif Pfig >= 13 and Pfig <= 17 then
        local dH = SI / 5
        x0, y0, x1, y1, x2, y2, x3, y3 = -SI2 + dH, -0.6 * dH, -SI2 + 2 * dH, -0.6 * dH, -SI2 + 2 * dH, 0, -SI2 + dH, 0
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

if
    track_bump == 2
    and Pfig ~= 2
    and Pfig ~= 6
    and Pfig ~= 10
    and Pfig ~= 14
    and Pfig ~= 19
    and Pfig ~= 17
    and Pfig ~= 22
then
    obj.copybuffer("cache:PC1", "tmp")
    obj.setoption("drawtarget", "tempbuffer", SID, SID)
    obj.load("figure", "四角形", 0xffffff, 1)
    obj.setoption("blend", "alpha_add")
    obj.drawpoly(-SI2, -SI2, 0, SI2, -SI2, 0, SI2, SI2, 0, -SI2, SI2, 0)
    obj.drawpoly(0, -SI, 0, 0, -SI, 0, SI2, -SI2, 0, -SI2, -SI2, 0)
    obj.drawpoly(SI, 0, 0, SI, 0, 0, SI2, SI2, 0, SI2, -SI2, 0)
    obj.drawpoly(0, SI, 0, 0, SI, 0, -SI2, SI2, 0, SI2, SI2, 0)
    obj.drawpoly(-SI, 0, 0, -SI, 0, 0, -SI2, -SI2, 0, -SI2, SI2, 0)
    obj.copybuffer("obj", "cache:PC1")
    obj.setoption("blend", "alpha_sub")
    obj.draw(-SI, 0, 0)
    obj.draw(SI, 0, 0)
    obj.draw(0, -SI, 0)
    obj.draw(0, SI, 0)
end
obj.copybuffer("obj", "tmp")
obj.effect("単色化", "輝度を保持する", 0, "color", color)

fix_alpha_sub_workaround("object")