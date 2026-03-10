--label:tim2\装飾\罫線T.anm
---$track:制御点数
---min=1
---max=16
---step=1
local track_control_point_count = 4

---$track:スナップX
---min=1
---max=500
---step=1
local track_snap_x = 30

---$track:スナップY
---min=1
---max=500
---step=1
local track_snap_y = 30

---$value:制御点座標
local control_points = { -30, -80, 80, -80, -140, 74, -130, 0 }

RuledlineT = RuledlineT or {}
RuledlineT.typ = 2
local control_point_count = math.floor(track_control_point_count)
local snap_x = track_snap_x
local snap_y = track_snap_y
obj.setanchor("control_points", control_point_count)
local posX = {}
local posY = {}
for i = 1, control_point_count do
    posX[i] = (math.floor(control_points[2 * i - 1] / snap_x - 0.5) + 1) * snap_x
    posY[i] = (math.floor(control_points[2 * i] / snap_y - 0.5) + 1) * snap_y
end
local maxX = math.max(unpack(posX))
local minX = math.min(unpack(posX))
local maxY = math.max(unpack(posY))
local minY = math.min(unpack(posY))
RuledlineT.cx = (maxX + minX) * 0.5
RuledlineT.cy = (maxY + minY) * 0.5
RuledlineT.Tw = maxX - minX
RuledlineT.Th = maxY - minY
for i = 1, control_point_count do
    posX[i] = posX[i] - RuledlineT.cx
    posY[i] = posY[i] - RuledlineT.cy
end
RuledlineT.LPX = {}
RuledlineT.LPY = {}
RuledlineT.LPX[1] = -RuledlineT.Tw * 0.5
RuledlineT.LPY[1] = -RuledlineT.Th * 0.5
local A = RuledlineT.Th / RuledlineT.Tw
for i = 1, control_point_count do
    if A * posX[i] > posY[i] then
        RuledlineT.LPX[#RuledlineT.LPX + 1] = posX[i]
    else
        RuledlineT.LPY[#RuledlineT.LPY + 1] = posY[i]
    end
end
table.sort(RuledlineT.LPX)
table.sort(RuledlineT.LPY)
