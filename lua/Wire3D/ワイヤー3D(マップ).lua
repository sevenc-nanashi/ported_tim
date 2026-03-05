--label:tim2\ワイヤー3D.anm\ワイヤー3D(マップ)
--track0:横分割数,1,100,10,1
--track1:縦分割数,1,100,10,1
--track2:ライン幅,1,1000,2

WireT_c_nw = math.floor(obj.track0)
WireT_c_nh = math.floor(obj.track1)
WireT_line = obj.track2

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
