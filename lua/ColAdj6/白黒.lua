--label:tim2\T_Color_Module.anm\白黒
---$track:R%
---min=-500
---max=500
---step=0.1
local rename_me_track0 = 100

---$track:G%
---min=-500
---max=500
---step=0.1
local rename_me_track1 = 100

---$track:B%
---min=-500
---max=500
---step=0.1
local rename_me_track2 = 100

---$track:W%
---min=-500
---max=500
---step=0.1
local rename_me_track3 = 100

---$value:C%
local C = 100

---$value:M%
local M = 100

---$value:Y%
local Y = 100

---$value:色付け/chk
local Ck = 0

---$value:└着色/col
local col = 0xff0000

---$value:ガンマ値
local gm = 100

local R = rename_me_track0 * 0.01
local G = rename_me_track1 * 0.01
local B = rename_me_track2 * 0.01
local W = rename_me_track3 * 0.01
C = (C or 100) * 0.01
M = (M or 100) * 0.01
Y = (Y or 100) * 0.01
Ck = Ck or 0
col = col or 0xffffff
gm = gm or 100
if gm < 1 then
    gm = 1
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.EnhGrayScale(userdata, w, h, R, G, B, C, M, Y, W, 100 / gm, Ck, col)
obj.putpixeldata(userdata)
