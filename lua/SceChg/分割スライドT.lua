--label:tim2\シーンチェンジ\シーンチェンジセットT.scn
---$track:単独量
---min=0
---max=100
---step=0.1
local rename_me_track0 = 40

---$track:モード
---min=0
---max=3
---step=1
local rename_me_track1 = 1

---$value:分割数
local N = 5

---$check:縦
local rename_me_check0 = false

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", "alpha_sub")

local T = obj.getvalue("scenechange")
local L = rename_me_track0 * 0.01
N = math.floor(N)
local MD = 2 * math.floor(rename_me_track1)
local dL = (N * L - 1) / (N - 1)
if dL <= 0 then
    dL = 0
end

local ow = obj.w
local oh = obj.h
local ow2 = 0.5 * ow
local oh2 = 0.5 * oh

if rename_me_check0 then
    for k = 1, N do
        local kk
        if MD % 4 <= 1 then
            kk = k
        else
            kk = N - k + 1
        end

        local x0 = (k - 1) * ow / N - ow2
        local x1 = k * ow / N - ow2
        if (kk - 1) * (L - dL) + L <= T then --全表示
            obj.drawpoly(x0, -oh2, 0, x1, -oh2, 0, x1, oh, 0, x0, oh, 0)
        else
            dh = (T - (kk - 1) * (L - dL)) * oh / L
            if dh <= 0 then
                dh = 0
            end
            if MD >= 4 and (MD + k) % 2 == 0 then
                obj.drawpoly(x0, oh2 - dh, 0, x1, oh2 - dh, 0, x1, oh2, 0, x0, oh2, 0)
            else
                obj.drawpoly(x0, -oh2, 0, x1, -oh2, 0, x1, dh - oh2, 0, x0, dh - oh2, 0)
            end
        end
    end --k
else
    for k = 1, N do
        local kk
        if MD % 4 <= 1 then
            kk = k
        else
            kk = N - k + 1
        end

        local y0 = (k - 1) * oh / N - oh2
        local y1 = k * oh / N - oh2
        if (kk - 1) * (L - dL) + L <= T then --全表示
            obj.drawpoly(-ow2, y0, 0, ow2, y0, 0, ow2, y1, 0, -ow2, y1, 0)
        else
            dw = (T - (kk - 1) * (L - dL)) * ow / L
            if dw <= 0 then
                dw = 0
            end
            if MD >= 4 and (MD + k) % 2 == 0 then
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
