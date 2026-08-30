--label:${ROOT_CATEGORY}\装飾\@ストロークT
---$track:進捗度
---min=0
---max=100
---step=0.01
local track_progress = 50

---$track:左端残し
---min=0
---max=2000
---step=1
local track_keep_left_edge = 0

---$track:右端残し
---min=0
---max=2000
---step=1
local track_keep_right_edge = 0

---$select:繰返モード
---根本固定=1
---先端固定=2
---ランダム=3
local track_mode = 1

---$track:軌道精度
---min=1
---max=1000
---step=1
local path_resolution = 30

---$check:環状軌道
local check_closed_path = 0

---$select:軌道
---曲線=0
---円=1
local path_type = 1

---$check:先頭調整
local check_adjust_leading_edge = 0

---$value:幅変動[%]
local width_percentages = { 100, 100, 100 }

---$value:z軸方向
local z_positions = { 0, 0, 0 }

---$track:最大ランダム長[%]
---min=5
---max=100
---step=1
local max_random_length_percent = 50

---$track:乱数シード
---min=0
---max=100000
---step=1
local random_seed = 0

---$check:フレームバッファ表示
local check_show_framebuffer = 0

--hide@max_random_length_percent:track_mode~=3
--hide@random_seed:track_mode~=3

local left_edge_length = track_keep_left_edge
local right_edge_length = track_keep_right_edge
local t = track_progress * 0.01
local repeat_mode = track_mode --1は根本固定、2は先端固定、3はランダム
check_adjust_leading_edge = check_adjust_leading_edge or 2 --互換用

T_STROKE_DRAW = function()
    local interpolation_t
    if path_type == 0 then
        interpolation_t = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            if t <= 0.5 then
                s = t + 0.5
                return ((1 - s) * (1 - s) * x0 + (1 + 2 * s - 2 * s * s) * x1 + s * s * x2) / 2,
                    ((1 - s) * (1 - s) * y0 + (1 + 2 * s - 2 * s * s) * y1 + s * s * y2) / 2
            else
                s = t - 0.5
                return ((1 - s) * (1 - s) * x1 + (1 + 2 * s - 2 * s * s) * x2 + s * s * x3) / 2,
                    ((1 - s) * (1 - s) * y1 + (1 + 2 * s - 2 * s * s) * y2 + s * s * y3) / 2
            end
        end
    elseif path_type == 1 then
        interpolation_t = function(t, x0, y0, x1, y1, x2, y2, x3, y3) --正方形配置で円になるように特殊な計算
            local s, ax, ay, cx, cy, control_x, control_y, ex, ey, fx, fy
            if t <= 0.5 then
                t = t + 0.5
                ex, ey = (x0 + x1) * 0.5, (y0 + y1) * 0.5
                control_x, control_y = x1, y1
                fx, fy = (x1 + x2) * 0.5, (y1 + y2) * 0.5
            else
                t = t - 0.5
                ex, ey = (x1 + x2) * 0.5, (y1 + y2) * 0.5
                control_x, control_y = x2, y2
                fx, fy = (x2 + x3) * 0.5, (y2 + y3) * 0.5
            end
            t = math.tan(math.pi * 0.5 * t * 0.5)
            ax, ay = (1 - t) * ex + t * control_x, (1 - t) * ey + t * control_y
            s = 2 * t / (1 + t)
            cx, cy = (1 - s) * control_x + s * fx, (1 - s) * control_y + s * fy
            s = t * (1 + t) / (1 + t * t)
            return (1 - s) * ax + s * cx, (1 - s) * ay + s * cy
        end
    else
        interpolation_t = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            return (1 - t) * x1 + t * x2, (1 - t) * y1 + t * y2
        end
    end

    local distance_cor = function(point_x, point_y, item_count)
        local long = {}
        local i_px = {}
        local i_py = {}
        i_px[0], i_py[0] = point_x[0], point_y[0]
        i_px[item_count], i_py[item_count] = point_x[item_count], point_y[item_count]
        long[0] = 0
        for i = 1, item_count do
            long[i] = long[i - 1] + math.sqrt((point_x[i] - point_x[i - 1]) ^ 2 + (point_y[i] - point_y[i - 1]) ^ 2)
        end
        local con = long[item_count] / item_count
        local m = 1
        for i = 1, item_count - 1 do
            local dis = i * con
            while dis > long[m] do
                m = m + 1
            end
            local rate = (dis - long[m - 1]) / (long[m] - long[m - 1])
            i_px[i] = point_x[m - 1] + rate * (point_x[m] - point_x[m - 1])
            i_py[i] = point_y[m - 1] + rate * (point_y[m] - point_y[m - 1])
        end
        return i_px, i_py, math.floor(long[item_count])
    end

    local cal_array = function(t, arr) --倍率用
        local item_count = #arr
        if item_count == 1 then
            return arr[1]
        end
        local s = 1 + t * (item_count - 1)
        local q1 = math.floor(s)
        local q0 = math.max(1, q1 - 1)
        local q2 = math.min(item_count, q1 + 1)
        local q3 = math.min(item_count, q1 + 2)
        s = s - q1
        return obj.interpolation(s, arr[q0], arr[q1], arr[q2], arr[q3])
    end

    local cal_array2 = function(t, arr) --Z座標用
        local item_count = #arr
        if item_count == 1 then
            return arr[1]
        end
        local s = 1 + t * (item_count - 1)
        local q1 = math.floor(s)
        local q0 = q1 - 1
        local q2 = q1 + 1
        local q3 = q1 + 2
        s = s - q1
        if q0 < 1 then
            q0 = 2 * arr[1] - arr[2]
        else
            q0 = arr[q0]
        end
        q1 = arr[q1]
        if q2 > item_count then
            q2 = 2 * arr[item_count] - arr[item_count - 1]
        else
            q2 = arr[q2]
        end
        if q3 > item_count + 1 then
            q3 = 3 * arr[item_count] - 2 * arr[item_count - 1]
        elseif q3 > item_count then
            q3 = 2 * arr[item_count] - arr[item_count - 1]
        else
            q3 = arr[q3]
        end
        return obj.interpolation(s, q0, q1, q2, q3)
    end

    local rvec = function(x1, x2, y1, y2, h)
        local dx = x1 - x2
        local dy = y1 - y2
        local dr = math.sqrt(dx * dx + dy * dy)
        return 0.5 * dx * h / dr, 0.5 * dy * h / dr
    end

    local ac_n = T_STROKE_ANCHOR_COUNT
    local anc = T_STROKE_ANCHORS

    if check_closed_path == 1 then
        ac_n = ac_n + 1
        anc[2 * ac_n - 1], anc[2 * ac_n] = anc[1], anc[2]
    end

    local w0, h0 = obj.getpixel() --オリジナルサイズ
    max_random_length_percent = math.min(1, math.max(0.05, max_random_length_percent * 0.01))
    path_resolution = math.min(1000, math.max(1, math.floor(path_resolution)))
    left_edge_length = math.floor(math.min(left_edge_length, w0 - 2))
    right_edge_length = math.floor(math.min(right_edge_length, w0 - left_edge_length - 1))
    obj.copybuffer("cache:ori", "object") --オリジナルを保存

    obj.effect("クリッピング", "左", left_edge_length, "右", right_edge_length) --両端をカット
    local w, h = w0 - (left_edge_length + right_edge_length), h0 --両端カットサイズ
    obj.copybuffer("cache:moyou", "object") --両端カットを保存

    for i = 1, #width_percentages do
        width_percentages[i] = width_percentages[i] * 0.01
    end

    --座標データ作成

    local anc_x = {}
    local anc_y = {}

    for i = 1, ac_n do
        anc_x[i] = anc[2 * i - 1]
        anc_y[i] = anc[2 * i]
    end

    if check_closed_path == 1 then
        anc_x[0] = anc_x[ac_n - 1]
        anc_y[0] = anc_y[ac_n - 1]
        anc_x[ac_n + 1] = anc_x[2]
        anc_y[ac_n + 1] = anc_y[2]
    else
        anc_x[0] = 2 * anc_x[1] - anc_x[2]
        anc_y[0] = 2 * anc_y[1] - anc_y[2]
        anc_x[ac_n + 1] = 2 * anc_x[ac_n] - anc_x[ac_n - 1]
        anc_y[ac_n + 1] = 2 * anc_y[ac_n] - anc_y[ac_n - 1]
    end

    --距離、座標設定
    local pos_x = {}
    local pos_y = {}
    local long = {}
    for i = 1, ac_n - 1 do
        pos_x[i] = {}
        pos_y[i] = {}
        for k = 0, path_resolution do
            pos_x[i][k], pos_y[i][k] = interpolation_t(
                k / path_resolution,
                anc_x[i - 1],
                anc_y[i - 1],
                anc_x[i],
                anc_y[i],
                anc_x[i + 1],
                anc_y[i + 1],
                anc_x[i + 2],
                anc_y[i + 2]
            )
        end
        pos_x[i], pos_y[i], long[i] = distance_cor(pos_x[i], pos_y[i], path_resolution)
    end

    --距離再計算
    local long_s = {}
    long_s[0] = 0
    for i = 1, ac_n - 1 do
        long_s[i] = long_s[i - 1] + long[i]
    end
    local all_long = long_s[ac_n - 1]

    --輪郭計算用
    for i = 2, ac_n - 1 do
        pos_x[i][-1] = pos_x[i - 1][path_resolution - 1]
        pos_y[i][-1] = pos_y[i - 1][path_resolution - 1]
    end
    for i = 1, ac_n - 2 do
        pos_x[i][path_resolution + 1] = pos_x[i + 1][1]
        pos_y[i][path_resolution + 1] = pos_y[i + 1][1]
    end
    if check_closed_path == 1 then
        pos_x[1][-1] = pos_x[ac_n - 1][path_resolution - 1]
        pos_y[1][-1] = pos_y[ac_n - 1][path_resolution - 1]
        pos_x[ac_n - 1][path_resolution + 1] = pos_x[1][1]
        pos_y[ac_n - 1][path_resolution + 1] = pos_y[1][1]
    else
        pos_x[1][-1] = 2 * pos_x[1][0] - pos_x[1][1]
        pos_y[1][-1] = 2 * pos_y[1][0] - pos_y[1][1]
        pos_x[ac_n - 1][path_resolution + 1] = 2 * pos_x[ac_n - 1][path_resolution]
            - pos_x[ac_n - 1][path_resolution - 1]
        pos_y[ac_n - 1][path_resolution + 1] = 2 * pos_y[ac_n - 1][path_resolution]
            - pos_y[ac_n - 1][path_resolution - 1]
    end

    --幅調整
    local heights = {}
    for i = 1, ac_n - 1 do
        heights[i] = {}
        for k = 0, path_resolution do
            local t = (k * long[i] / path_resolution + long_s[i - 1]) / all_long
            heights[i][k] = h * cal_array(t, width_percentages)
        end
    end

    --輪郭作成
    local pos_tx = {}
    local pos_ty = {}
    local pos_bx = {}
    local pos_by = {}
    for i = 1, ac_n - 1 do
        pos_tx[i] = {}
        pos_ty[i] = {}
        pos_bx[i] = {}
        pos_by[i] = {}
        for k = 0, path_resolution do
            local dx, dy = rvec(pos_x[i][k - 1], pos_x[i][k + 1], pos_y[i][k - 1], pos_y[i][k + 1], heights[i][k])
            pos_tx[i][k] = pos_x[i][k] + dy
            pos_ty[i][k] = pos_y[i][k] - dx
            pos_bx[i][k] = pos_x[i][k] - dy
            pos_by[i][k] = pos_y[i][k] + dx
        end
    end

    --ブロック最大値を計算
    local acmax = 1
    local acmaxb = 1
    if t < 1 then
        while long_s[acmaxb] < t * (all_long - left_edge_length - right_edge_length) + left_edge_length do
            acmaxb = acmaxb + 1
        end
        acmax = acmaxb
        while
            long_s[acmax]
            < t * (all_long - left_edge_length - right_edge_length) + left_edge_length + right_edge_length
        do
            acmax = acmax + 1
        end
    else
        acmax = ac_n - 1
        acmaxb = acmax
    end

    --ブロック単位で画像作成
    local xlong = t * (all_long - left_edge_length - right_edge_length)
    local sft = 0

    if repeat_mode < 3 then
        if repeat_mode == 1 then
            sft = left_edge_length - w
        else
            sft = (left_edge_length + xlong) % w - w
        end

        for i = 1, acmax do
            obj.setoption("drawtarget", "tempbuffer", long[i], h)
            obj.setoption("blend", "alpha_add2")
            local repeat_count = math.floor((long[i] - sft) / w) + 1
            local longh = long[i] * 0.5

            if repeat_mode == 1 or (repeat_mode == 2 and i ~= acmax and (i ~= acmaxb or acmax == acmaxb)) then
                for j = 0, repeat_count do
                    obj.draw(-longh + sft + w * (j + 0.5))
                end
            elseif (i == acmax and acmax == acmaxb) or (i == acmaxb and acmax ~= acmaxb) then
                for j = 0, repeat_count do
                    obj.draw(-longh + xlong + left_edge_length - long_s[i - 1] - w * (j + 0.5))
                end
            end

            sft = -((long[i] - sft) % w)
            obj.copybuffer("cache:line" .. i, "tempbuffer")
        end
    else
        local y1 = h * 0.5
        local y0 = -y1
        local rn_dw = max_random_length_percent * w

        local a = {}
        a[-2] = 0
        a[-1] = w
        a[0] = 0
        local d_l = -2 * w + left_edge_length
        local rl = left_edge_length
        for i = 1, acmax do
            obj.setoption("drawtarget", "tempbuffer", long[i], h)
            obj.setoption("blend", "alpha_add2")
            local n = 0

            repeat
                a[n + 1] = obj.rand(a[n], a[n] + rn_dw, i, n + 1000 + random_seed)
                n = n + 1
                if a[n] > w then
                    a[n] = w
                end
                a[n + 1] = obj.rand(a[n] - rn_dw, a[n], i, n + 1000 + random_seed)
                n = n + 1
                if a[n] < 0 then
                    a[n] = 0
                end
                rl = rl + (2 * a[n - 1] - a[n - 2] - a[n])
            until rl >= long[i]

            local sht = -long[i] * 0.5 + d_l
            for i = 0, n, 2 do
                local u0, u1, x0, x1, du

                u0 = a[i - 2]
                u1 = a[i - 1]
                du = u1 - u0
                x0 = sht
                x1 = sht + du
                obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, 0, u1, 0, u1, h, u0, h)
                sht = sht + du

                u0 = a[i]
                u1 = a[i - 1]
                du = u1 - u0
                x0 = sht + du
                x1 = sht
                obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, 0, u1, 0, u1, h, u0, h)
                sht = sht + du
            end
            obj.copybuffer("cache:line" .. i, "tempbuffer")

            a[-2] = a[n - 2]
            a[-1] = a[n - 1]
            a[0] = a[n]
            rl = rl - long[i]
            d_l = rl - (2 * a[n - 1] - a[n - 2] - a[n])
        end
    end

    obj.copybuffer("object", "cache:line1")
    obj.effect("クリッピング", "左", left_edge_length)
    obj.effect("領域拡張", "左", left_edge_length)
    obj.copybuffer("tempbuffer", "object")
    obj.copybuffer("object", "cache:ori")
    obj.effect("クリッピング", "右", w + right_edge_length)
    obj.draw((-long[1] + left_edge_length) * 0.5, 0)
    obj.copybuffer("cache:line1", "tempbuffer")

    for i = acmaxb, acmax do
        local x = xlong + left_edge_length - long_s[i - 1] - long[i] * 0.5
        obj.copybuffer("object", "cache:line" .. i)
        obj.effect("斜めクリッピング", "角度", -90, "中心X", x, "ぼかし", 0)
        obj.copybuffer("tempbuffer", "object")
        obj.copybuffer("object", "cache:ori")
        obj.effect("クリッピング", "左", w + left_edge_length)
        obj.draw(x + right_edge_length * 0.5 - check_adjust_leading_edge * 0.5, 0)
        obj.copybuffer("cache:line" .. i, "tempbuffer")
    end

    if check_show_framebuffer == 0 then
        --最大最小検出
        local max_x = pos_tx[1][0]
        local min_x = pos_tx[1][0]
        local max_y = pos_ty[1][0]
        local min_y = pos_ty[1][0]
        for i = 1, acmax do
            for k = 0, path_resolution do
                max_x = math.max(pos_tx[i][k], pos_bx[i][k], max_x)
                min_x = math.min(pos_tx[i][k], pos_bx[i][k], min_x)
                max_y = math.max(pos_ty[i][k], pos_by[i][k], max_y)
                min_y = math.min(pos_ty[i][k], pos_by[i][k], min_y)
            end
        end

        local ww = max_x - min_x
        local hh = max_y - min_y
        local cw = (max_x + min_x) * 0.5
        local ch = (max_y + min_y) * 0.5

        obj.setoption("drawtarget", "tempbuffer", ww, hh)
        obj.setoption("blend", "alpha_add2")
        for i = 1, acmax do
            obj.copybuffer("object", "cache:line" .. i)
            for k = 0, path_resolution - 1 do
                local x0, y0 = pos_tx[i][k] - cw, pos_ty[i][k] - ch
                local x1, y1 = pos_tx[i][k + 1] - cw, pos_ty[i][k + 1] - ch
                local x2, y2 = pos_bx[i][k + 1] - cw, pos_by[i][k + 1] - ch
                local x3, y3 = pos_bx[i][k] - cw, pos_by[i][k] - ch
                local u0 = long[i] * k / path_resolution
                local u1 = long[i] * (k + 1) / path_resolution
                obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, 0, u1, 0, u1, h, u0, h)
            end
        end
        obj.load("tempbuffer")
        obj.setoption("blend", 0)
        obj.cx = -cw
        obj.cy = -ch
    else
        local zz = {}
        for i = 1, acmax do
            zz[i] = {}
            for k = 0, path_resolution do
                local t = (k * long[i] / path_resolution + long_s[i - 1]) / all_long
                zz[i][k] = cal_array2(t, z_positions)
            end
        end
        obj.setoption("drawtarget", "framebuffer")
        for i = 1, acmax do
            obj.copybuffer("object", "cache:line" .. i)
            obj.cx = 0
            obj.cy = 0
            for k = 0, path_resolution - 1 do
                local x0, y0 = pos_tx[i][k], pos_ty[i][k]
                local x1, y1 = pos_tx[i][k + 1], pos_ty[i][k + 1]
                local x2, y2 = pos_bx[i][k + 1], pos_by[i][k + 1]
                local x3, y3 = pos_bx[i][k], pos_by[i][k]
                local u0 = long[i] * k / path_resolution
                local u1 = long[i] * (k + 1) / path_resolution
                obj.drawpoly(
                    x1,
                    y1,
                    zz[i][k + 1],
                    x0,
                    y0,
                    zz[i][k],
                    x3,
                    y3,
                    zz[i][k],
                    x2,
                    y2,
                    zz[i][k + 1],
                    u1,
                    0,
                    u0,
                    0,
                    u0,
                    h,
                    u1,
                    h
                )
            end
        end
        obj.setoption("blend", 0)
    end
end

---$embed
local common = require("common")
if common.is_last_chain() then
    T_STROKE_DRAW()
    T_STROKE_ANCHORS = nil
    T_STROKE_ANCHOR_COUNT = nil
end
