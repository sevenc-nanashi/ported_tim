--label:tim2\T_Color_Module.anm\特定色域変換T
--track0:色相範囲,0,360,100
--track1:彩度範囲,0,255,255
--track2:輝度調整,0,500,100
--track3:境界補正,1,360,2
--value@col1:変更前/col,0x0000ff
--value@col2: 変更後/col,0xff0000
--value@pS:彩度調整,100
local pS2 = pS or 100
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ChangeToColor(
    userdata,
    w,
    h,
    col1,
    col2,
    obj.track0,
    obj.track1,
    pS2 * 0.01,
    obj.track2 * 0.01,
    obj.track3
)
obj.putpixeldata(userdata)
