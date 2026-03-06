--label:tim2\変形\モーフィング.anm
---$track:ﾎﾟｲﾝﾄ数
---min=1
---max=14
---step=1
local track_point_count = 3

---$track:画像番号
---min=1
---max=2
---step=1
local track_image_index = 1

---$track:ﾎﾟｲﾝﾄｻｲｽﾞ
---min=0
---max=500
---step=1
local track_point_size = 30

---$track:ﾌｫﾝﾄｻｲｽﾞ
---min=0
---max=500
---step=1
local track_size = 30

---$color:ポイント色
local pcol = 0xffffff

---$color:文字色
local fcol = 0x0

---$value:座標
local pos = { -100, 0, 0, 0, 100, 0 }

---$check:ポイント表示
local check0 = false

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

local AN = track_point_count
Morphing_PC = track_image_index
Morphing_check0 = check0

if Morphing_obj == nil then
    Morphing_obj = {}
end

Morphing_Pst = {}
Morphing_Pst.pcol = pcol
Morphing_Pst.psize = track_point_size
Morphing_Pst.fcol = fcol
Morphing_Pst.fsize = track_size

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
