--label:${ROOT_CATEGORY}\トラックバー制御
--param:1
--[[
軌道調整Ｔ.objの軌道番号と
設定の[]の中の数字を揃える
--]]

local point_index, ratio = math.modf(obj.getpoint("index"))
local original_ratio = ratio
local start_value = obj.getpoint(point_index)
local point_count = obj.getpoint("num")
local end_value = point_index == point_count and obj.getpoint(point_index) or obj.getpoint(point_index + 1)
local orbit_index = obj.getpoint("param")
local link_index = obj.getpoint("link")

local control_1_x, control_1_y, control_2_x, control_2_y, orbit_target

if orbit_index > 0 then
    control_1_x = T_BEZIER_ORBITS[orbit_index][1]
    control_1_y = T_BEZIER_ORBITS[orbit_index][2]
    control_2_x = T_BEZIER_ORBITS[orbit_index][3]
    control_2_y = T_BEZIER_ORBITS[orbit_index][4]
    orbit_target = T_BEZIER_ORBITS[orbit_index][5]
else
    orbit_index = -orbit_index
    orbit_target = math.floor(orbit_index / 100000000)
    orbit_index = orbit_index - orbit_target * 100000000
    control_1_x = math.floor(orbit_index / 1000000)
    orbit_index = orbit_index - control_1_x * 1000000
    control_1_y = math.floor(orbit_index / 10000)
    orbit_index = orbit_index - control_1_y * 10000
    control_2_x = math.floor(orbit_index / 100)
    orbit_index = orbit_index - control_2_x * 100
    control_2_y = orbit_index
    control_1_x, control_1_y, control_2_x, control_2_y =
        control_1_x / 50, control_1_y / 50, control_2_x / 50, control_2_y / 50
end

local lower_time = 0
local upper_time = 1
for i = 1, 10 do
    local mid_time = (lower_time + upper_time) * 0.5
    local inverse_time = 1 - mid_time
    local curve_x = (
        3 * inverse_time * inverse_time * control_1_x + (3 * inverse_time * control_2_x + mid_time) * mid_time
    ) * mid_time
    if ratio < curve_x then
        upper_time = mid_time
    else
        lower_time = mid_time
    end
end
local mid_time = (lower_time + upper_time) * 0.5
local inverse_time = 1 - mid_time
ratio = (3 * inverse_time * inverse_time * control_1_y + (3 * inverse_time * control_2_y + mid_time) * mid_time)
    * mid_time

if orbit_target == 0 then
    return start_value + (end_value - start_value) * ratio
else
    if orbit_target == link_index + 1 then
        return start_value + (end_value - start_value) * ratio
    else
        -- return obj.getpoint("default")
        return start_value + (end_value - start_value) * original_ratio
    end
end
