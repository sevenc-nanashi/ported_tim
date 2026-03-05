--label:tim2\罫線T.anm\罫線T(斜線)
--track0:斜線数,1,16,1,1
--track1:線幅,1,500,6,1
--track2:長さ%,0,200,100
--track3:形状,0,2,0,1
--value@Scl:線色/col,0xffffff
--value@posSL:アンカー,{0,0}
RuledlineT = RuledlineT or {}
local apnum = obj.track0
obj.setanchor("posSL", apnum)
RuledlineT.SLX = RuledlineT.SLX or {}
RuledlineT.SLY = RuledlineT.SLY or {}
RuledlineT.Scl = RuledlineT.Scl or {}
RuledlineT.SLC = RuledlineT.SLC or {}
RuledlineT.Sdw = RuledlineT.Sdw or {}
RuledlineT.Pdw = RuledlineT.Pdw or {}
local num = (#RuledlineT.SLX or 0) + 1
RuledlineT.Scl[num] = Scl
RuledlineT.Sdw[num] = obj.track1
RuledlineT.Pdw[num] = (1 - obj.track2 * 0.01) * 0.5
RuledlineT.SLC[num] = math.floor(obj.track3)
RuledlineT.SLX[num] = {}
RuledlineT.SLY[num] = {}
for k = 1, apnum do
    RuledlineT.SLX[num][k] = posSL[2 * k - 1]
    RuledlineT.SLY[num][k] = posSL[2 * k]
end
