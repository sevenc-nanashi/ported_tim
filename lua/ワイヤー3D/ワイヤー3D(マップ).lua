--label:${ROOT_CATEGORY}\変形\@ワイヤー3D
---$track:横分割数
---min=1
---max=100
---step=1
local track_horizontal_split_count = 10

---$track:縦分割数
---min=1
---max=100
---step=1
local track_vertical_split_count = 10

---$track:ライン幅
---min=1
---max=1000
---step=0.1
local track_width = 2

T_WIRE_HORIZONTAL_SPLIT_COUNT = math.floor(track_horizontal_split_count)
T_WIRE_VERTICAL_SPLIT_COUNT = math.floor(track_vertical_split_count)
T_WIRE_LINE_WIDTH = track_width

local w, h = obj.getpixel()
obj.pixeloption("type", "yc")
obj.pixeloption("get", "obj")

T_WIRE_DATA = {}

for i = 0, T_WIRE_HORIZONTAL_SPLIT_COUNT do
    T_WIRE_DATA[i] = {}
    for j = 0, T_WIRE_VERTICAL_SPLIT_COUNT do
        local yi, cbi, cri, ai =
            obj.getpixel((w - 1) * i / T_WIRE_HORIZONTAL_SPLIT_COUNT, (h - 1) * j / T_WIRE_VERTICAL_SPLIT_COUNT, "yc")
        T_WIRE_DATA[i][j] = yi / 4096
    end
end
