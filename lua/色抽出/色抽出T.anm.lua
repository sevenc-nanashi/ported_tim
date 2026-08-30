--label:${ROOT_CATEGORY}\抽出
---$track:輝度範囲
---min=0
---max=4096
---step=1
local track_luminance_range = 300

---$track:色差範囲
---min=0
---max=4096
---step=1
local track_color_difference_range = 300

---$track:境界補正
---min=0
---max=5
---step=1
local track_boundary_adjust = 0

---$color:抽出色
local extraction_color = nil

---$check:簡易処理
local check_simple_processing = true

if extraction_color == nil then
    return
end
obj.effect("領域拡張", "上", 10, "下", 10, "右", 10, "左", 10, "塗りつぶし", 1)
obj.copybuffer("cache:ori", "object")
obj.setoption("drawtarget", "tempbuffer", obj.getpixel())
if not check_simple_processing then
    obj.copybuffer("tempbuffer", "object")
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_add")
    obj.draw()
    obj.copybuffer("object", "tempbuffer")
end
obj.effect(
    "カラーキー",
    "輝度範囲",
    track_luminance_range,
    "色差範囲",
    track_color_difference_range,
    "境界補正",
    track_boundary_adjust,
    "基準色",
    extraction_color
)
obj.copybuffer("tempbuffer", "cache:ori")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.effect("クリッピング", "上", 10, "下", 10, "右", 10, "左", 10)
