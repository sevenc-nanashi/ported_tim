--label:tim2\未分類\罫線T.anm
---$track:位置1
---min=1
---max=1000
---step=1
local track_position_1 = 1

---$track:位置2
---min=0
---max=1000
---step=1
local track_position_2 = 0

---$track:ｻｲｽﾞ補正
---min=0
---max=1000
---step=0.1
local track_size_adjust = 100

---$check:行列反転
local Rev = 0

---$check:自動配置
local AutoSet = 0

---$value:└配置順[0..3]
local ord = 0

---$check:└最終ｵﾌﾞｼﾞｪｸﾄ
local Lastobj = 0

---$check:ｻｲｽﾞ自動調整
local check0 = false

local CalIJ = function(n, nx, ny, Rev)
    local i, j
    if Rev == 1 then
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
local n1 = math.floor(track_position_1 - 1)
local n2 = math.floor(track_position_2 - 1)
local i1, j1, i2, j2
if AutoSet == 0 then
    n1 = n1 % (nx * ny)
    n2 = n2 % (nx * ny)
    i1, j1 = CalIJ(n1, nx, ny, Rev)
    if track_position_2 > 0 then
        i2, j2 = CalIJ(n2, nx, ny, Rev)
        i1, i2 = math.min(i1, i2), math.max(i1, i2)
        j1, j2 = math.min(j1, j2), math.max(j1, j2)
    else
        i2, j2 = i1, j1
    end
else
    local ord = (ord or 0) % 4
    RuledlineTASN = (RuledlineTASN or -1) + 1
    n1 = RuledlineTASN % (nx * ny)
    i1, j1 = CalIJ(n1, nx, ny, Rev)
    if ord == 1 or ord == 3 then
        i1 = nx - i1 + 1
    end
    if ord == 2 or ord == 3 then
        j1 = ny - j1 + 1
    end
    i2, j2 = i1, j1
    if Lastobj == 1 then
        RuledlineTASN = nil
    end
end
local dx = (RT.X[i1] + RT.X[i2 + 1]) * 0.5
local dy = (RT.Y[j1] + RT.Y[j2 + 1]) * 0.5
local zm = track_size_adjust * 0.01
if check0 then
    local w, h = obj.getpixel()
    local tx = RT.X[i2 + 1] - RT.X[i1]
    local ty = RT.Y[j2 + 1] - RT.Y[j1]
    zm = zm * math.min(tx / w, ty / h, 1)
end
obj.draw(dx + RT.CX, dy + RT.CY, 0, zm)
