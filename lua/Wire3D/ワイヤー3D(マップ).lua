--label:tim2\未分類\ワイヤー3D.anm
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

WireT_c_nw = math.floor(track_horizontal_split_count)
WireT_c_nh = math.floor(track_vertical_split_count)
WireT_line = track_width

local w, h = obj.getpixel()
obj.pixeloption("type", "yc")
obj.pixeloption("get", "obj")

WireT_data = {}

for i = 0, WireT_c_nw do
    WireT_data[i] = {}
    for j = 0, WireT_c_nh do
        local yi, cbi, cri, ai = obj.getpixel((w - 1) * i / WireT_c_nw, (h - 1) * j / WireT_c_nh, "yc")
        WireT_data[i][j] = yi / 4096
    end
end
