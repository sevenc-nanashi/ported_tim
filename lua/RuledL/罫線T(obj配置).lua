--label:tim2\装飾\罫線T.anm
---$track:開始位置
---min=1
---max=1000
---step=1
local track_start_position = 1

---$track:終了位置(0で単独)
---min=0
---max=1000
---step=1
local track_end_position = 0

---$track:サイズ補正[%]
---min=0
---max=1000
---step=0.1
local track_size_adjust_percent = 100

---$check:行列反転
local check_reverse_rows_columns = false

---$check:自動配置
local check_auto_place = false

---$select:└配置順
---左上=0
---右上=1
---左下=2
---右下=3
local select_order = 0

---$check:└最終オブジェクト
local check_last_object = false

---$check:サイズ自動調整
local check_auto_size_adjust = false

local is_enabled = function(value)
    return value == true or value == 1
end

local CalIJ = function(n, nx, ny, is_reverse_order)
    local i, j
    if is_reverse_order then
        j = n % ny
        i = (n - j) / ny
    else
        i = n % nx
        j = (n - i) / nx
    end
    return i + 1, j + 1
end
local RT = RuledlineTcrd
local nx = #RT.X - 1
local ny = #RT.Y - 1
local is_reverse_order = is_enabled(check_reverse_rows_columns)
local n1 = math.floor(track_start_position - 1)
local n2 = math.floor(track_end_position - 1)
local i1, j1, i2, j2
if not is_enabled(check_auto_place) then
    n1 = n1 % (nx * ny)
    n2 = n2 % (nx * ny)
    i1, j1 = CalIJ(n1, nx, ny, is_reverse_order)
    if track_end_position > 0 then
        i2, j2 = CalIJ(n2, nx, ny, is_reverse_order)
        i1, i2 = math.min(i1, i2), math.max(i1, i2)
        j1, j2 = math.min(j1, j2), math.max(j1, j2)
    else
        i2, j2 = i1, j1
    end
else
    local ord = (select_order or 0) % 4
    RuledlineTASN = (RuledlineTASN or -1) + 1
    n1 = RuledlineTASN % (nx * ny)
    i1, j1 = CalIJ(n1, nx, ny, is_reverse_order)
    if ord == 1 or ord == 3 then
        i1 = nx - i1 + 1
    end
    if ord == 2 or ord == 3 then
        j1 = ny - j1 + 1
    end
    i2, j2 = i1, j1
    if is_enabled(check_last_object) then
        RuledlineTASN = nil
    end
end
local dx = (RT.X[i1] + RT.X[i2 + 1]) * 0.5
local dy = (RT.Y[j1] + RT.Y[j2 + 1]) * 0.5
local zm = track_size_adjust_percent * 0.01
if is_enabled(check_auto_size_adjust) then
    local w, h = obj.getpixel()
    local tx = RT.X[i2 + 1] - RT.X[i1]
    local ty = RT.Y[j2 + 1] - RT.Y[j1]
    zm = zm * math.min(tx / w, ty / h, 1)
end
obj.draw(dx + RT.CX, dy + RT.CY, 0, zm)
