--label:tim2\カスタムフレア.anm
---$track:移動量
---min=-500
---max=500
---step=0.1
local track_move_amount = 0

---$track:合成モード
---min=0
---max=1
---step=1
local track_blend_mode = 0

---$color:ベースカラー
local col = 0x5588ff

---$check:位置移動
local mv = 0

---$value:座標
local pos = { -200, -100, 0, 0, 0, 0 }

if mv == 0 then
    obj.setanchor("pos", 2, "line", "xyz")
    CustomFlareXX = pos[1]
    CustomFlareYY = pos[2]
    CustomFlareZZ = pos[3]
    CustomFlareCX = pos[4]
    CustomFlareCY = pos[5]
    CustomFlareCZ = pos[6]
else
    obj.setanchor("pos", 4, "line", "xyz", "inout")
    local s = track_move_amount * 0.01
    CustomFlareXX = (1 - s) * pos[1] + s * pos[7]
    CustomFlareYY = (1 - s) * pos[2] + s * pos[8]
    CustomFlareZZ = (1 - s) * pos[3] + s * pos[9]
    CustomFlareCX = (1 - s) * pos[4] + s * pos[10]
    CustomFlareCY = (1 - s) * pos[5] + s * pos[11]
    CustomFlareCZ = (1 - s) * pos[6] + s * pos[12]
end
CustomFlaredX = CustomFlareCX - CustomFlareXX
CustomFlaredY = CustomFlareCY - CustomFlareYY
CustomFlaredZ = CustomFlareCZ - CustomFlareZZ
CustomFlareColor = col
CustomFlareW, CustomFlareH = obj.getpixel()
CustomFlareMode = 1 + 3 * track_blend_mode
