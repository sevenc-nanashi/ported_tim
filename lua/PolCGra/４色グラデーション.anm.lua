--label:tim2\未分類
---$track:幅
---min=0
---max=100
---step=0.1
local track_width = 0

---$track:中心ｽﾞﾚ1
---min=-100
---max=100
---step=0.1
local track_center_offset_1 = 0

---$track:中心ｽﾞﾚ2
---min=-100
---max=100
---step=0.1
local track_center_offset_2 = 0

---$track:中心ｽﾞﾚ3
---min=-100
---max=100
---step=0.1
local track_center_offset_3 = 0

---$value:色1
local col1 = 0x00ff00

---$value:色2
local col2 = 0xffff00

---$value:色3
local col3 = 0xff0000

---$value:色4
local col4 = 0x0000ff

local haba = track_width * obj.h / 100
local cen1 = -(obj.h + haba) / 4 + track_center_offset_1 * obj.h / 100
local cen2 = track_center_offset_2 * obj.h / 100
local cen3 = (obj.h + haba) / 4 + track_center_offset_3 * obj.h / 100
obj.effect("グラデーション", "color", col1, "color2", col2, "中心Y", cen1, "幅", haba, "type", 0)
obj.effect("グラデーション", "no_color", 1, "color2", col3, "中心Y", cen2, "幅", haba, "type", 0)
obj.effect("グラデーション", "no_color", 1, "color2", col4, "中心Y", cen3, "幅", haba, "type", 0)
