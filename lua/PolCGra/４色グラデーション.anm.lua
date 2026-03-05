--label:tim2
--track0:幅,0,100,0
--track1:中心ｽﾞﾚ1,-100,100,0
--track2:中心ｽﾞﾚ2,-100,100,0
--track3:中心ｽﾞﾚ3,-100,100,0
--value@col1:色1,0x00ff00
--value@col2:色2,0xffff00
--value@col3:色3,0xff0000
--value@col4:色4,0x0000ff
local haba = obj.track0 * obj.h / 100
local cen1 = -(obj.h + haba) / 4 + obj.track1 * obj.h / 100
local cen2 = obj.track2 * obj.h / 100
local cen3 = (obj.h + haba) / 4 + obj.track3 * obj.h / 100
obj.effect("グラデーション", "color", col1, "color2", col2, "中心Y", cen1, "幅", haba, "type", 0)
obj.effect("グラデーション", "no_color", 1, "color2", col3, "中心Y", cen2, "幅", haba, "type", 0)
obj.effect("グラデーション", "no_color", 1, "color2", col4, "中心Y", cen3, "幅", haba, "type", 0)
