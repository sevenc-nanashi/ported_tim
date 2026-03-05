--label:tim2\T_Color_Module.anm
---$track:色数
---min=1
---max=512
---step=1
local rename_me_track0 = 16

---$track:X分割
---min=1
---max=20
---step=1
local rename_me_track1 = 4

---$track:Y分割
---min=1
---max=20
---step=1
local rename_me_track2 = 4

ClusterReductionIdxC_T = {}
local idn = rename_me_track0
local nx = rename_me_track1
local ny = rename_me_track2
local idT = {}
local w, h = obj.getpixel()
local dx, dy = w / nx, h / ny
ClusterReductionIdxC_T.T = {}
local k = 0
for j = 0, ny - 1 do
    for i = 0, nx - 1 do
        k = k + 1
        if k <= idn then
            local col, a = obj.getpixel((i + 0.5) * dx, (j + 0.5) * dy, "col")
            ClusterReductionIdxC_T.T[k] = col
        end
    end
end
ClusterReductionIdxC_T.N = idn
obj.setoption("drawtarget", "tempbuffer")
obj.copybuffer("tmp", "obj")
obj.load("figure", "四角形", 0xff0000, 6, 1)
k = 0
for j = 0, ny - 1 do
    for i = 0, nx - 1 do
        k = k + 1
        if k <= idn then
            obj.draw((i + 0.5) * dx - w * 0.5, (j + 0.5) * dy - 0.5 * h)
        end
    end
end
obj.copybuffer("obj", "tmp")
