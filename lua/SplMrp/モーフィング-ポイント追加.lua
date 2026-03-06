--label:tim2\変形\モーフィング.anm
---$track:ﾎﾟｲﾝﾄ数
---min=1
---max=16
---step=1
local track_point_count = 1

---$value:座標
local pos = { 0, 0 }

local AN = track_point_count
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
