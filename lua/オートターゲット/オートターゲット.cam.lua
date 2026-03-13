--label:tim2\カメラ制御
---$track:ターゲット
---min=1
---max=100
---step=0.01
local track_target_index = 1

---$track:カメラ距離
---min=0
---max=20000
---step=0.1
local camera_distance = 1024

---$track:イーズ
---min=0
---max=100
---step=0.1
local easing = 20

---$check:なめらか
local check_smooth = true

---$select:指定方法
---絶対値=0
---カメラからの相対値=1
---前ターゲットからの相対値=2
local target_set_method = 0

--group:ターゲット指定

---$value:ターゲット一覧
local targets = {}

---$track:ターゲット1
---min=0
---max=1000
---step=1
local tar1 = 0

---$track:ターゲット2
---min=0
---max=1000
---step=1
local tar2 = 0

---$track:ターゲット3
---min=0
---max=1000
---step=1
local tar3 = 0

---$track:ターゲット4
---min=0
---max=1000
---step=1
local tar4 = 0

---$track:ターゲット5
---min=0
---max=1000
---step=1
local tar5 = 0

---$track:ターゲット6
---min=0
---max=1000
---step=1
local tar6 = 0

---$track:ターゲット7
---min=0
---max=1000
---step=1
local tar7 = 0

---$track:ターゲット8
---min=0
---max=1000
---step=1
local tar8 = 0

---$track:ターゲット9
---min=0
---max=1000
---step=1
local tar9 = 0

---$track:ターゲット10
---min=0
---max=1000
---step=1
local tar10 = 0

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

local function is_enabled(value)
    return value == true or value == 1
end

target_set_method = math.floor(target_set_method)

local target = {}
local tarN
if #targets > 0 then
    target = targets
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

local tn = track_target_index
local CL = camera_distance
local ez = easing / 10
if tn > tarN then
    tn = tarN
end

if target_set_method == 1 then
    for i = 1, tarN do
        target[i] = target[i] + obj.layer
    end
elseif target_set_method == 2 then
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

if not is_enabled(check_smooth) then
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
