--label:tim2\T_Filter_Module.anm
---$track:強さ
---min=0
---max=1000
---step=0.1
local rename_me_track0 = 100

---$track:半径
---min=1
---max=100
---step=1
local rename_me_track1 = 1

---$check:アンシャープマスク
local rename_me_check0 = true

require("T_Filter_Module")
local St = rename_me_track0 * 0.01

if rename_me_check0 then
    local userdata, w, h = obj.getpixeldata()
    T_Filter_Module.SetPublicImage(userdata, w, h)
    obj.effect("ぼかし", "範囲", rename_me_track1, "サイズ固定", 1)
    userdata, w, h = obj.getpixeldata()
    T_Filter_Module.UnSharpMask(userdata, w, h, St)
    obj.putpixeldata(userdata)
else
    obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
    local userdata, w, h = obj.getpixeldata()
    T_Filter_Module.Sharp(userdata, w, h, St)
    obj.putpixeldata(userdata)
    obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
end
