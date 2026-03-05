--label:tim2\T_Color_Module.anm\メディアンカット減色
--track0:MC色数,0,500,16,1
--track1:CL色数,0,500,0,1
--value@col1:指定色1/col,""
--value@col2:指定色2/col,""
--value@col3:指定色3/col,""
--value@col4:指定色4/col,""
--value@col5:指定色5,""
--value@col6:指定色6,""
--value@col7:指定色7,""
--value@col8:指定色8,""
--value@col9:指定色9,""
--value@col10:指定色10,""
--value@Cap:色表示/chk,0
--check0:指定色を有効にする,0;
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
if ClusterReductionIdxC_T then
    T_Color_Module.DispReduction(userdata, w, h, ClusterReductionIdxC_T.N, ClusterReductionIdxC_T.T)
    ClusterReductionIdxC_T = nil
else
    local mN = obj.track0
    local cN = obj.track1
    local col = {}
    local colN = 0
    if obj.check0 then
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
