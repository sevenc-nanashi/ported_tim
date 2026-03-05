--label:tim2
---$track:指定位置X
---min=-10000
---max=10000
---step=1
local rename_me_track0 = 0

---$track:指定位置Y
---min=-10000
---max=10000
---step=1
local rename_me_track1 = 0

---$track:α調整
---min=1
---max=255
---step=1
local rename_me_track2 = 255

---$track:透明度
---min=0
---max=100
---step=0.1
local rename_me_track3 = 0

---$value:塗り潰し色/col
local col = 0xffcccc

---$check:改良計算
local rename_me_check0 = true

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
        rename_me_track0,
        rename_me_track1,
        rename_me_track2,
        rename_me_check0,
        1 - rename_me_track3 * 0.01
    )
)
