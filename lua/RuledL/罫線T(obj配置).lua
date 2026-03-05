--label:tim2\罫線T.anm\罫線T(obj配置)
--track0:位置1,1,1000,1,1
--track1:位置2,0,1000,0,1
--track2:ｻｲｽﾞ補正,0,1000,100
--value@Rev:行列反転/chk,0
--value@AutoSet:自動配置/chk,0
--value@ord:└配置順[0..3],0
--value@Lastobj:└最終ｵﾌﾞｼﾞｪｸﾄ/chk,0
--check0:ｻｲｽﾞ自動調整,0;
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
local n1 = math.floor(obj.track0 - 1)
local n2 = math.floor(obj.track1 - 1)
local i1, j1, i2, j2
if AutoSet == 0 then
    n1 = n1 % (nx * ny)
    n2 = n2 % (nx * ny)
    i1, j1 = CalIJ(n1, nx, ny, Rev)
    if obj.track1 > 0 then
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
local zm = obj.track2 * 0.01
if obj.check0 then
    local w, h = obj.getpixel()
    local tx = RT.X[i2 + 1] - RT.X[i1]
    local ty = RT.Y[j2 + 1] - RT.Y[j1]
    zm = zm * math.min(tx / w, ty / h, 1)
end
obj.draw(dx + RT.CX, dy + RT.CY, 0, zm)
