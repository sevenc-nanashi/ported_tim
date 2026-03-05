--label:tim2
--track0:しきい値,0,255,10,1
--track1:ずれ,-500,500,10,1
--track2:ぼかし,0,500,0,1
--track3:ｶﾞﾗｽ強度,-1000,1000,100
--value@GIL:ガラス画像,1
--value@Edg:境界を透過/chk,0
--value@Bcol:マップ背景色/col,0x0
--value@PT:パターン,0
--check0:マップ表示,0;
local Sh = obj.track0
local bkb = obj.track2
PT = math.abs(PT or 0)
require("T_CrackedGlass_Module")
local Pr = { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
local w, h = obj.getpixel()
obj.effect("ぼかし", "範囲", bkb, "サイズ固定", 1)
obj.copybuffer("cache:CG_ORG", "obj")
obj.load("layer", GIL or 1, true)
local wg, hg = obj.getpixel()
local Zm
if w * hg < h * wg then
    Zm = h / hg
else
    Zm = w / wg
end
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw(0, 0, 0, Zm)
obj.copybuffer("obj", "tmp")
local userdata, w, h = obj.getpixeldata()
T_CrackedGlass_Module.CrackedGlass(userdata, w, h, Sh, PT, obj.check0, Bcol or 0)
obj.putpixeldata(userdata)
if not obj.check0 then
    obj.copybuffer("tmp", "obj")
    obj.copybuffer("obj", "cache:CG_ORG")
    local T = obj.track1
    local CS = obj.track3
    obj.effect(
        "ディスプレイスメントマップ",
        "param0",
        T,
        "param1",
        T,
        "ぼかし",
        0,
        "元のサイズに合わせる",
        1,
        "type",
        0,
        "name",
        "*tempbuffer",
        "mode",
        0,
        "calc",
        0
    )
    userdata, w, h = obj.getpixeldata()
    T_CrackedGlass_Module.AddGlass(userdata, w, h, CS, Edg, Sh)
    obj.putpixeldata(userdata)
end
obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect = unpack(Pr)
