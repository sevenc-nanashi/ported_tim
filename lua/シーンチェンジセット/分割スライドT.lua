--label:tim2\シーンチェンジ\@シーンチェンジセットT
---$track:単独量
---min=0
---max=100
---step=0.1
local track_single_amount = 40

---$select:モード
---通常=0
---逆順=1
---交互=2
---逆順・交互=3
local select_mode = 1

---$track:分割数
---min=2
---max=100
---step=1
local track_split_count = 5

---$check:縦
local check_vertical = false

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", "alpha_sub")

local T = obj.getvalue("scenechange")
local L = track_single_amount * 0.01
local N = math.max(2, math.floor(track_split_count))
local mode = math.floor(select_mode)
local reverse_order = mode % 2 == 1
local alternate_direction = mode >= 2
local dL = (N * L - 1) / (N - 1)
if dL <= 0 then
    dL = 0
end

local ow = obj.w
local oh = obj.h
local ow2 = 0.5 * ow
local oh2 = 0.5 * oh

if check_vertical then
    for k = 1, N do
        local kk = k
        if reverse_order then
            kk = N - k + 1
        end

        local x0 = (k - 1) * ow / N - ow2
        local x1 = k * ow / N - ow2
        if (kk - 1) * (L - dL) + L <= T then --全表示
            obj.drawpoly(x0, -oh2, 0, x1, -oh2, 0, x1, oh, 0, x0, oh, 0)
        else
            local dh = (T - (kk - 1) * (L - dL)) * oh / L
            if dh <= 0 then
                dh = 0
            end
            if alternate_direction and k % 2 == 0 then
                obj.drawpoly(x0, oh2 - dh, 0, x1, oh2 - dh, 0, x1, oh2, 0, x0, oh2, 0)
            else
                obj.drawpoly(x0, -oh2, 0, x1, -oh2, 0, x1, dh - oh2, 0, x0, dh - oh2, 0)
            end
        end
    end --k
else
    for k = 1, N do
        local kk = k
        if reverse_order then
            kk = N - k + 1
        end

        local y0 = (k - 1) * oh / N - oh2
        local y1 = k * oh / N - oh2
        if (kk - 1) * (L - dL) + L <= T then --全表示
            obj.drawpoly(-ow2, y0, 0, ow2, y0, 0, ow2, y1, 0, -ow2, y1, 0)
        else
            local dw = (T - (kk - 1) * (L - dL)) * ow / L
            if dw <= 0 then
                dw = 0
            end
            if alternate_direction and k % 2 == 0 then
                obj.drawpoly(ow2 - dw, y0, 0, ow2, y0, 0, ow2, y1, 0, ow2 - dw, y1, 0)
            else
                obj.drawpoly(-ow2, y0, 0, dw - ow2, y0, 0, dw - ow2, y1, 0, -ow2, y1, 0)
            end
        end
    end --k
end
obj.copybuffer("obj", "tmp")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
