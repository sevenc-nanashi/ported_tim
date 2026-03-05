--label:tim2\T_Color_Module.anm\減色パレット
--track0:色数,1,512,16,1
--track1:X分割,1,20,4,1
--track2:Y分割,1,20,4,1
ClusterReductionIdxC_T = {}
local idn = obj.track0
local nx = obj.track1
local ny = obj.track2
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
