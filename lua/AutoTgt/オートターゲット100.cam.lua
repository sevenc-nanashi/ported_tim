--label:tim2\カメラ制御
---$track:ﾀｰｹﾞｯﾄ
---min=100
---max=10000
---step=0.01
local rename_me_track0 = 100

---$track:ｶﾒﾗ距離
---min=0
---max=20000
---step=0.1
local rename_me_track1 = 1024

---$track:イーズ
---min=0
---max=100
---step=0.1
local rename_me_track2 = 20

---$track:なめらか
---min=0
---max=1
---step=0.1
local rename_me_track3 = 1

---$value:ターゲット1
local tar1 = nil

---$value:ターゲット2
local tar2 = nil

---$value:ターゲット3
local tar3 = nil

---$value:ターゲット4
local tar4 = nil

---$value:ターゲット5
local tar5 = nil

---$value:ターゲット6
local tar6 = nil

---$value:ターゲット7
local tar7 = nil

---$value:ターゲット8
local tar8 = nil

---$value:ターゲット9
local tar9 = nil

---$value:ターゲット10
local tar10 = nil

---$value:指定方法
local setM = 0

local type = function(v)
    local v = v
    local s = tostring(v)
    if s == v then
        return "string"
    end
    if s == "nil" then
        return "nil"
    end
    if s == "true" or s == "false" then
        return "boolean"
    end
    if string.find(s, "table:") then
        return "table"
    end
    if string.find(s, "function:") then
        return "function"
    end
    if string.find(s, "userdata:") then
        return "userdata"
    end
    return "number"
end

setM = math.floor(setM)

local target = {}
local tarN
if type(tar1) == "table" then
    target = tar1
    tarN = #target
else
    target = { tar1, tar2, tar3, tar4, tar5, tar6, tar7, tar8, tar9, tar10 }
    tarN = 10
    for i = 1, 10 do
        if type(target[i]) ~= "number" then
            tarN = i - 1
            break
        end
    end
end

local tn = rename_me_track0 * 0.01
local CL = rename_me_track1
local ez = rename_me_track2 / 10
if tn > tarN then
    tn = tarN
end

if setM == 1 then
    for i = 1, tarN do
        target[i] = target[i] + obj.layer
    end
elseif setM == 2 then
    local sum = obj.layer
    for i = 1, tarN do
        sum = sum + target[i]
        target[i] = sum
    end
end

local tarData = {}
for i = 1, tarN do
    target[i] = math.floor(target[i])
    if target[i] < 1 then
        target[i] = 1
    end
    tarData[i] = {
        x = obj.getvalue("layer" .. target[i] .. ".x"),
        y = obj.getvalue("layer" .. target[i] .. ".y"),
        z = obj.getvalue("layer" .. target[i] .. ".z"),
        rx = obj.getvalue("layer" .. target[i] .. ".rx"),
        ry = obj.getvalue("layer" .. target[i] .. ".ry"),
        rz = obj.getvalue("layer" .. target[i] .. ".rz"),
    }
end

local tn1 = math.floor(tn)
local tn2 = tn1 + 1
tn = tn - tn1

if ez ~= 0 then
    tn = math.exp(ez * (2 * tn - 1))
    local keisu = (math.exp(ez) + 1) / (math.exp(ez) - 1)
    tn = (1 + keisu * (tn - 1) / (tn + 1)) / 2
end
local tni = 1 - tn
if tn2 > tarN then
    tn2 = tarN
end

local cam = obj.getoption("camera_param")

local crxd, cryd, crzd

if rename_me_track3 == 0 then
    cam.tx = tni * tarData[tn1].x + tn * tarData[tn2].x
    cam.ty = tni * tarData[tn1].y + tn * tarData[tn2].y
    cam.tz = tni * tarData[tn1].z + tn * tarData[tn2].z

    crxd = tni * tarData[tn1].rx + tn * tarData[tn2].rx
    cryd = tni * tarData[tn1].ry + tn * tarData[tn2].ry
    crzd = tni * tarData[tn1].rz + tn * tarData[tn2].rz
else
    tn0 = tn1 - 1
    if tn0 < 1 then
        tn0 = 1
    end
    tn3 = tn2 + 1
    if tn3 > tarN then
        tn3 = tarN
    end

    local x0, y0, z0 = tarData[tn0].x, tarData[tn0].y, tarData[tn0].z
    local x1, y1, z1 = tarData[tn1].x, tarData[tn1].y, tarData[tn1].z
    local x2, y2, z2 = tarData[tn2].x, tarData[tn2].y, tarData[tn2].z
    local x3, y3, z3 = tarData[tn3].x, tarData[tn3].y, tarData[tn3].z
    cam.tx, cam.ty, cam.tz = obj.interpolation(tn, x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3)

    x0, y0, z0 = tarData[tn0].rx, tarData[tn0].ry, tarData[tn0].rz
    x1, y1, z1 = tarData[tn1].rx, tarData[tn1].ry, tarData[tn1].rz
    x2, y2, z2 = tarData[tn2].rx, tarData[tn2].ry, tarData[tn2].rz
    x3, y3, z3 = tarData[tn3].rx, tarData[tn3].ry, tarData[tn3].rz
    crxd, cryd, crzd = obj.interpolation(tn, x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3)
end

local sx = math.sin(crxd * math.pi / 180)
local cx = math.cos(crxd * math.pi / 180)
local sy = math.sin(cryd * math.pi / 180)
local cy = math.cos(cryd * math.pi / 180)
local sz = math.sin(crzd * math.pi / 180)
local cz = math.cos(crzd * math.pi / 180)

local cax = -sy
local cay = sx * cy
local caz = -cx * cy

local ux = cy * sz
local uy = -cx * cz + (sx * sz) * sy
local uz = -sx * cz - (cx * sz) * sy

cam.x = cam.tx + cax * CL
cam.y = cam.ty + cay * CL
cam.z = cam.tz + caz * CL
cam.ux = ux
cam.uy = uy
cam.uz = uz

obj.setoption("camera_param", cam)
