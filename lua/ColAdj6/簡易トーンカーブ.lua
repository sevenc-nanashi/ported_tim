--label:tim2\T_Color_Module.anm\簡易トーンカーブ
---$check:赤カーブ全体統一
local rename_me_check0 = true

---$value:データクリア/chk
local DCL = 0

--名前の後に全角スペースが入っている・・
require("T_Color_Module")
local DCL2 = DCL or 0
if T_ToneCurve_R == nil then
    T_Color_Module.SetToneCurve(0, 0, 0, 0, 1, 0, 0, 0, 0)
end
if T_ToneCurve_G == nil then
    T_Color_Module.SetToneCurve(1, 0, 0, 0, 1, 0, 0, 0, 0)
end
if T_ToneCurve_B == nil then
    T_Color_Module.SetToneCurve(2, 0, 0, 0, 1, 0, 0, 0, 0)
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.SimToneCurve(userdata, w, h, rename_me_check0)
obj.putpixeldata(userdata)
if DCL2 == 1 then
    T_ToneCurve_R = nil
    T_ToneCurve_G = nil
    T_ToneCurve_B = nil
end
