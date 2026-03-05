--label:tim2\モーフィング.anm\モーフィング-ポイント追加
--track0:ﾎﾟｲﾝﾄ数,1,16,1,1
--value@pos:座標,{0,0}
local AN = obj.track0
obj.setanchor("pos", AN)

local MP = Morphing_obj[Morphing_PC].pos
local Np = #MP
for i = 1, AN do
    MP[Np + i] = {}
    MP[Np + i].x = pos[2 * i - 1]
    MP[Np + i].y = pos[2 * i]
end

if obj.getoption("script_name", 1, true) ~= "モーフィング-ポイント追加@モーフィング" then
    Morphing_drawANC()
    Morphing_drawANC = nil
end
