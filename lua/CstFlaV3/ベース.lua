--label:tim2\カスタムフレア.anm\ベース
--track0:移動量,-500,500,0
--track1:合成モード,0,1,0,1
--value@col:ベースカラー/col,0x5588ff
--value@mv:位置移動/chk,0
--value@pos:座標,{-200,-100,0, 0,0,0}
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
    local s = obj.track0 * 0.01
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
CustomFlareMode = 1 + 3 * obj.track1
