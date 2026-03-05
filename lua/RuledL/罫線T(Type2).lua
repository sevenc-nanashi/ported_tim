--label:tim2\罫線T.anm\罫線T(Type2)
--track0:制御点数,1,16,4,1
--track1:ｽﾅｯﾌﾟX,1,500,30,1
--track2:ｽﾅｯﾌﾟY,1,500,30,1
--value@pos:座標,{-30,-80,80,-80,-140,74,-130,0}
RuledlineT = RuledlineT or {}
RuledlineT.typ = 2
local N = math.floor(obj.track0)
local SPx = obj.track1
local SPy = obj.track2
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
