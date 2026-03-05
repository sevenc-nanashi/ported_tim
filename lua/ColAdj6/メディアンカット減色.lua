--label:tim2\T_Color_Module.anm\メディアンカット減色
---$track:MC色数
---min=0
---max=500
---step=1
local rename_me_track0 = 16

---$track:CL色数
---min=0
---max=500
---step=1
local rename_me_track1 = 0

---$value:指定色1/col
local col1 = ""

---$value:指定色2/col
local col2 = ""

---$value:指定色3/col
local col3 = ""

---$value:指定色4/col
local col4 = ""

---$value:指定色5
local col5 = ""

---$value:指定色6
local col6 = ""

---$value:指定色7
local col7 = ""

---$value:指定色8
local col8 = ""

---$value:指定色9
local col9 = ""

---$value:指定色10
local col10 = ""

---$value:色表示/chk
local Cap = 0

---$check:指定色を有効にする
local rename_me_check0 = true

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
if ClusterReductionIdxC_T then
    T_Color_Module.DispReduction(userdata, w, h, ClusterReductionIdxC_T.N, ClusterReductionIdxC_T.T)
    ClusterReductionIdxC_T = nil
else
    local mN = rename_me_track0
    local cN = rename_me_track1
    local col = {}
    local colN = 0
    if rename_me_check0 then
        local cc = { col1, col2, col3, col4, col5, col6, col7, col8, col9, col10 }
        for i = 1, 10 do
            if cc[i] ~= nil and cc[i] ~= "" then
                colN = colN + 1
                col[colN] = cc[i]
            end
        end
    end
    T_Color_Module.MCutReduction(userdata, w, h, mN, cN, Cap, colN, col)
end
obj.putpixeldata(userdata)
