--label:tim2\モーフィング.anm\モーフィング-ポイント指定
--track0:ﾎﾟｲﾝﾄ数,1,14,3,1
--track1:画像番号,1,2,1,1
--track2:ﾎﾟｲﾝﾄｻｲｽﾞ,0,500,30,1
--track3:ﾌｫﾝﾄｻｲｽﾞ,0,500,30,1
--value@pcol:ポイント色/col,0xffffff
--value@fcol:文字色/col,0x0
--value@pos:座標,{-100,0,0,0,100,0}
--check0:ポイント表示,0;

Morphing_drawANC = function()
    if Morphing_check0 then
        local MO = Morphing_obj[Morphing_PC]
        local MP = MO.pos
        local N = #MP
        obj.setoption("drawtarget", "tempbuffer", MO.w, MO.h)
        obj.draw()
        obj.load("figure", "円", Morphing_Pst.pcol, Morphing_Pst.psize)
        for i = 1, N do
            obj.draw(MP[i].x, MP[i].y)
        end
        obj.setfont("", Morphing_Pst.fsize, 0, Morphing_Pst.fcol)
        for i = 1, N do
            obj.load("text", i)
            obj.draw(MP[i].x, MP[i].y)
        end
        obj.load("tempbuffer")
    end
    Morphing_Pst = nil
    Morphing_check0 = nil
    Morphing_PC = nil
end

local AN = obj.track0
Morphing_PC = obj.track1
Morphing_check0 = obj.check0

if Morphing_obj == nil then
    Morphing_obj = {}
end

Morphing_Pst = {}
Morphing_Pst.pcol = pcol
Morphing_Pst.psize = obj.track2
Morphing_Pst.fcol = fcol
Morphing_Pst.fsize = obj.track3

local w, h = obj.getpixel()
local w2, h2 = w * 0.5, h * 0.5
Morphing_obj[Morphing_PC] = {}
local MO = Morphing_obj[Morphing_PC]
MO.layer = obj.layer
MO.w = w
MO.h = h
MO.pos = {}
local MP = MO.pos
MP[1] = { x = -w2, y = -h2 }
MP[2] = { x = w2, y = -h2 }
MP[3] = { x = w2, y = h2 }
MP[4] = { x = -w2, y = h2 }

obj.setanchor("pos", AN)

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
