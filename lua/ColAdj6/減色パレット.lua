--label:tim2\色調整\T_Color_Module.anm
--filter
---$track:色数
---min=1
---max=512
---step=1
local track_color_count = 16

---$track:X分割
---min=1
---max=20
---step=1
local track_x_split = 4

---$track:Y分割
---min=1
---max=20
---step=1
local track_y_split = 4

ClusterReductionIdxC_T = {}
local idn = track_color_count
local nx = track_x_split
local ny = track_y_split
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
obj.setoption("drawtarget", "tempbuffer", obj.w, obj.h)
obj.copybuffer("tempbuffer", "object")
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
obj.copybuffer("object", "tempbuffer")
