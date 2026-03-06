--label:tim2\未分類
---$track:指定位置X
---min=-10000
---max=10000
---step=1
local track_target_position_x = 0

---$track:指定位置Y
---min=-10000
---max=10000
---step=1
local track_target_position_y = 0

---$track:α調整
---min=1
---max=255
---step=1
local track_alpha = 255

---$track:透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$color:塗り潰し色
local col = 0xffcccc

---$check:改良計算
local check0 = true

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
        track_target_position_x,
        track_target_position_y,
        track_alpha,
        check0,
        1 - track_opacity * 0.01
    )
)
