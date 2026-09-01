--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:MC色数
---min=0
---max=500
---step=1
local track_median_cut_color_count = 16

---$track:CL色数
---min=0
---max=500
---step=1
local track_cluster_color_count = 0

---$check:指定色を有効にする
local check_enable_specified_colors = false

---$color:指定色1
local specified_color_1 = nil

---$color:指定色2
local specified_color_2 = nil

---$color:指定色3
local specified_color_3 = nil

---$color:指定色4
local specified_color_4 = nil

---$color:指定色5
local specified_color_5 = nil

---$color:指定色6
local specified_color_6 = nil

---$color:指定色7
local specified_color_7 = nil

---$color:指定色8
local specified_color_8 = nil

---$color:指定色9
local specified_color_9 = nil

---$color:指定色10
local specified_color_10 = nil

---$check:色表示
local check_show_colors = false

--hide@specified_color_1:check_enable_specified_colors==0
--hide@specified_color_2:check_enable_specified_colors==0
--hide@specified_color_3:check_enable_specified_colors==0
--hide@specified_color_4:check_enable_specified_colors==0
--hide@specified_color_5:check_enable_specified_colors==0
--hide@specified_color_6:check_enable_specified_colors==0
--hide@specified_color_7:check_enable_specified_colors==0
--hide@specified_color_8:check_enable_specified_colors==0
--hide@specified_color_9:check_enable_specified_colors==0
--hide@specified_color_10:check_enable_specified_colors==0

-- require("T_Color_Module")
local color_module = obj.module("tim2")
local pixel_data, width, height = obj.getpixeldata("object", "bgra")
if T_CLUSTER_REDUCTION_PALETTE then
    -- color_module.DispReduction(pixel_data, width, height, T_CLUSTER_REDUCTION_PALETTE.count, T_CLUSTER_REDUCTION_PALETTE.colors)
    local colors = {}
    for i = 1, T_CLUSTER_REDUCTION_PALETTE.count do
        colors[i] = T_CLUSTER_REDUCTION_PALETTE.colors[i]
    end
    color_module.color_disp_reduction(pixel_data, width, height, colors)
    T_CLUSTER_REDUCTION_PALETTE = nil
else
    local median_cut_color_count = track_median_cut_color_count
    local cluster_color_count = track_cluster_color_count
    local specified_colors = {}
    local specified_color_count = 0
    if check_enable_specified_colors then
        local color_candidates = {
            specified_color_1,
            specified_color_2,
            specified_color_3,
            specified_color_4,
            specified_color_5,
            specified_color_6,
            specified_color_7,
            specified_color_8,
            specified_color_9,
            specified_color_10,
        }
        for i = 1, 10 do
            if color_candidates[i] ~= nil and color_candidates[i] ~= "" then
                specified_color_count = specified_color_count + 1
                specified_colors[specified_color_count] = color_candidates[i]
            end
        end
    end
    -- color_module.MCutReduction(pixel_data, width, height, median_cut_color_count, cluster_color_count, check_show_colors, specified_colors)
    color_module.color_mcut_reduction(
        pixel_data,
        width,
        height,
        median_cut_color_count,
        cluster_color_count,
        check_show_colors,
        specified_colors
    )
end
obj.putpixeldata("object", pixel_data, width, height, "bgra")
