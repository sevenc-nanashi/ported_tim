--label:tim2\罫線T.anm
---$track:制御点数
---min=1
---max=16
---step=1
local track_control_point_count = 4

---$track:ｽﾅｯﾌﾟX
---min=1
---max=500
---step=1
local track_x = 30

---$track:ｽﾅｯﾌﾟY
---min=1
---max=500
---step=1
local track_y = 30

---$value:座標
local pos = { -30, -80, 80, -80, -140, 74, -130, 0 }

RuledlineT = RuledlineT or {}
RuledlineT.typ = 2
local N = math.floor(track_control_point_count)
local SPx = track_x
local SPy = track_y
obj.setanchor("pos", N)
local posX = {}
local posY = {}
for i = 1, N do
    posX[i] = (math.floor(pos[2 * i - 1] / SPx - 0.5) + 1) * SPx
    posY[i] = (math.floor(pos[2 * i] / SPy - 0.5) + 1) * SPy
end
local maxX = math.max(unpack(posX))
local minX = math.min(unpack(posX))
local maxY = math.max(unpack(posY))
local minY = math.min(unpack(posY))
RuledlineT.cx = (maxX + minX) * 0.5
RuledlineT.cy = (maxY + minY) * 0.5
RuledlineT.Tw = maxX - minX
RuledlineT.Th = maxY - minY
for i = 1, N do
    posX[i] = posX[i] - RuledlineT.cx
    posY[i] = posY[i] - RuledlineT.cy
end
RuledlineT.LPX = {}
RuledlineT.LPY = {}
RuledlineT.LPX[1] = -RuledlineT.Tw * 0.5
RuledlineT.LPY[1] = -RuledlineT.Th * 0.5
local A = RuledlineT.Th / RuledlineT.Tw
for i = 1, N do
    if A * posX[i] > posY[i] then
        RuledlineT.LPX[#RuledlineT.LPX + 1] = posX[i]
    else
        RuledlineT.LPY[#RuledlineT.LPY + 1] = posY[i]
    end
end
table.sort(RuledlineT.LPX)
table.sort(RuledlineT.LPY)
