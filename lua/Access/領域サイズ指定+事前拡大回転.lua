--label:tim2\未分類\サイズ修正T.anm
---$track:幅
---min=0
---max=5000
---step=0.1
local width = 300

---$track:高さ
---min=0
---max=5000
---step=0.1
local height = 300

---$track:回転角
---min=-3600
---max=3600
---step=0.1
local angle = 0

---$track:拡大率
---min=0
---max=5000
---step=0.1
local scale = 100

if width == 0 or height == 0 then
    -- width/heightのどちらかが0の場合は「C++ exception」というログが出るので、
    -- 虚無を描画して回避する（この場合はサイズ0の円を描画する）
    obj.load("figure", "円", 0, 0)
    return
end
obj.setoption("drawtarget", "tempbuffer", width, height)
obj.draw(0, 0, 0, scale * 0.01, 1, 0, 0, angle)
obj.load("tempbuffer")