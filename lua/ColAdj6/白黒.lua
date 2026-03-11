--label:tim2\色調整\@T_Color_Module.anm
--filter
---$track:R%
---min=-500
---max=500
---step=0.1
local red = 100

---$track:G%
---min=-500
---max=500
---step=0.1
local green = 100

---$track:B%
---min=-500
---max=500
---step=0.1
local blue = 100

---$track:W%
---min=-500
---max=500
---step=0.1
local white = 100

---$track:C%
---min=-500
---max=500
---step=0.1
local cyan = 100

---$track:M%
---min=-500
---max=500
---step=0.1
local magenta = 100

---$track:Y%
---min=-500
---max=500
---step=0.1
local yellow = 100

---$color:色付け
local col = nil

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local gamma = 100

red = red * 0.01
green = green * 0.01
blue = blue * 0.01
white = white * 0.01
cyan = (cyan or 100) * 0.01
magenta = (magenta or 100) * 0.01
yellow = (yellow or 100) * 0.01
-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_enh_grayscale(userdata, w, h, red, green, blue, cyan, magenta, yellow, white, 100 / gamma, col)
obj.putpixeldata("object", userdata, w, h, "bgra")
