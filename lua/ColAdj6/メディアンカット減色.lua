--label:tim2\T_Color_Module.anm
---$track:MC色数
---min=0
---max=500
---step=1
local track_mc_color_count = 16

---$track:CL色数
---min=0
---max=500
---step=1
local track_cl_color_count = 0

---$color:指定色1
local col1 = ""

---$color:指定色2
local col2 = ""

---$color:指定色3
local col3 = ""

---$color:指定色4
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

---$check:色表示
local Cap = 0

---$check:指定色を有効にする
local check0 = true

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
if ClusterReductionIdxC_T then
    T_Color_Module.DispReduction(userdata, w, h, ClusterReductionIdxC_T.N, ClusterReductionIdxC_T.T)
    ClusterReductionIdxC_T = nil
else
    local mN = track_mc_color_count
    local cN = track_cl_color_count
    local col = {}
    local colN = 0
    if check0 then
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
