--label:tim2
--track0:ワイプ量,0,100,50
--track1:ぼかし,0,500,0
--track2:読込先,0,100,0,1
--check0:暗い所から透過,0;
require("T_Color_Module")

local T = obj.track0
local bl = obj.track1
local id = obj.track2
local w, h = obj.getpixel()

obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()

if id > 0 then
    require("extbuffer")
    extbuffer.read(id)
end

obj.effect("色調補正", "ｺﾝﾄﾗｽﾄ", 100 + T, "彩度", 100 - T)
obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 1)

if obj.check0 then
    obj.effect("反転", "輝度反転", 1)
end

if T < 50 then
    obj.effect("単色化", "color", 0x000000, "輝度を保持する", 0, "強さ", 100 - 2 * T)
else
    obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 0, "強さ", 2 * T - 100)
end

local userdata, w, h = obj.getpixeldata()
T_Color_Module.ShiftChannels(userdata, w, h, 1, 1, 2, 3)
obj.putpixeldata(userdata)

obj.effect("ぼかし", "範囲", bl, "サイズ固定", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.copybuffer("obj", "tmp")
