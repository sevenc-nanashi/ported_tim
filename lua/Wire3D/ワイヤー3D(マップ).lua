--label:tim2\ワイヤー3D.anm\ワイヤー3D(マップ)
---$track:横分割数
---min=1
---max=100
---step=1
local rename_me_track0 = 10

---$track:縦分割数
---min=1
---max=100
---step=1
local rename_me_track1 = 10

---$track:ライン幅
---min=1
---max=1000
---step=0.1
local rename_me_track2 = 2

WireT_c_nw = math.floor(rename_me_track0)
WireT_c_nh = math.floor(rename_me_track1)
WireT_line = rename_me_track2

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
