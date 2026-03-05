--label:tim2\T_Color_Module.anm
---$track:中心
---min=-255
---max=255
---step=0.1
local rename_me_track0 = 0

---$track:強度
---min=-200
---max=200
---step=0.1
local rename_me_track1 = 100

---$track:明るさ
---min=-255
---max=255
---step=0.1
local rename_me_track2 = 0

---$track:なめらか
---min=0
---max=100
---step=0
local rename_me_track3 = 50

---$value:カーブサイズ
local Csiz = 260

---$check:カーブ表示
local rename_me_check0 = true

require("T_Color_Module")
if rename_me_check0 then
    obj.load("figure", "四角形", 0xffffff, math.max(100, Csiz or 260))
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ExtendedContrast(
    userdata,
    w,
    h,
    rename_me_track0,
    rename_me_track1,
    rename_me_track2,
    rename_me_track3 / 100,
    rename_me_check0
)
obj.putpixeldata(userdata)
