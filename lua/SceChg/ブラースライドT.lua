--label:tim2\シーンチェンジ\@シーンチェンジセットT.scn
---$track:ブラー量
---min=0
---max=5000
---step=0.1
local track_blur_amount = 50

---$select:流れ方向
---横=0
---縦=1
local select_flow_direction = 0

---$track:分割数
---min=1
---max=100
---step=1
local track_split_count = 20

local calP = function(s, N)
    local t

    if N > 2 then
        local ss = s
        if s > N * 0.5 then
            ss = N - s
        end
        if ss > 0.5 then
            t = 0.25 + (math.sqrt((8 * ss - 4) * (N - 2) + 1) - 1) / (8 * (N - 2))
        else
            t = ss * 0.5
        end
        if s > N * 0.5 then
            t = 1 - t
        end
    else
        t = s / N
    end

    return t
end

local range = track_blur_amount * 0.5
local stype = math.floor(select_flow_direction)
local split_count = math.floor(track_split_count)

local TF = obj.totalframe - 1
local N = (TF + 2) * 0.5
local s = obj.frame -- math.floor(obj.getvalue("scenechange") * TF)

local w, h = obj.getpixel()
local w2, h2 = w / 2, h / 2

obj.copybuffer("cache:ch", "object")
obj.copybuffer("cache:after", "framebuffer")
obj.setoption("drawtarget", "tempbuffer", w, h)

if stype == 0 then
    obj.drawpoly(-w2, -h2, 0, 0, -h2, 0, 0, h2, 0, -w2, h2, 0)
    obj.copybuffer("object", "cache:after")
    obj.drawpoly(0, -h2, 0, w2, -h2, 0, w2, h2, 0, 0, h2, 0)
    obj.copybuffer("object", "tempbuffer")
    obj.effect("方向ブラー", "範囲", range, "角度", -90, "サイズ固定", 1)
    local dx = 1 / split_count
    local dw = w / split_count
    for i = 0, split_count - 1 do
        local x0 = s * 0.5 + i * dx
        local x1 = x0 + dx
        local u0 = w * calP(x0, N)
        local u1 = w * calP(x1, N)
        x0 = -w2 + i * dw
        x1 = x0 + dw
        obj.drawpoly(x0, -h2, 0, x1, -h2, 0, x1, h2, 0, x0, h2, 0, u0, 0, u1, 0, u1, h, u0, h)
    end
    if s == 0 then
        obj.copybuffer("obj", "cache:ch")
        obj.effect("斜めクリッピング", "角度", -90, "ぼかし", w / 3, "中心X", -w / 6)
        obj.draw()
    end
    if s == TF then
        obj.load("framebuffer")
        obj.effect("斜めクリッピング", "角度", 90, "ぼかし", w / 3, "中心X", w / 6)
        obj.draw()
    end
else
    obj.drawpoly(-w2, -h2, 0, w2, -h2, 0, w2, 0, 0, -w2, 0, 0)
    obj.copybuffer("obj", "frm")
    obj.drawpoly(-w2, 0, 0, w2, 0, 0, w2, h2, 0, -w2, h2, 0)
    obj.copybuffer("obj", "tmp")
    obj.effect("方向ブラー", "範囲", range, "角度", 0, "サイズ固定", 1)
    local dy = 1 / split_count
    local dh = h / split_count
    for i = 0, split_count - 1 do
        local y0 = s * 0.5 + i * dy
        local y1 = y0 + dy
        local v0 = h * calP(y0, N)
        local v1 = h * calP(y1, N)
        y0 = -h2 + i * dh
        y1 = y0 + dh
        obj.drawpoly(-w2, y0, 0, w2, y0, 0, w2, y1, 0, -w2, y1, 0, 0, v0, w, v0, w, v1, 0, v1)
    end
    if s == 0 then
        obj.copybuffer("obj", "cache:ch")
        obj.effect("斜めクリッピング", "角度", 0, "ぼかし", h / 3, "中心Y", -h / 6)
        obj.draw()
    end
    if s == TF then
        obj.load("framebuffer")
        obj.effect("斜めクリッピング", "角度", 180, "ぼかし", h / 3, "中心Y", h / 6)
        obj.draw()
    end
end

obj.copybuffer("object", "tempbuffer")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
