--label:tim2
--track0:指定位置X,-10000,10000,0,1
--track1:指定位置Y,-10000,10000,0,1
--track2:α調整,1,255,255,1
--track3:透明度,0,100,0
--value@col:塗り潰し色/col,0xffcccc
--check0:改良計算,1;

require("T_Alpha_Module")

obj.setanchor("track", 0)
local r, g, b = RGB(col)
local userdata, w, h = obj.getpixeldata()
obj.putpixeldata(
    T_Alpha_Module.AlphaFillColor(
        userdata,
        w,
        h,
        r,
        g,
        b,
        obj.track0,
        obj.track1,
        obj.track2,
        obj.check0,
        1 - obj.track3 * 0.01
    )
)
