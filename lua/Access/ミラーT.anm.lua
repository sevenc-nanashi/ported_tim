--label:tim2
---$track:透明度
---min=0
---max=100
---step=0.1
local rename_me_track0 = 0

---$track:境目調整
---min=-5000
---max=5000
---step=0.1
local rename_me_track1 = 0

---$track:ぼかし
---min=0
---max=300
---step=0.1
local rename_me_track2 = 10

---$track:基準
---min=-100
---max=100
---step=0.1
local rename_me_track3 = 100

---$color:色1
local col = 0x000000

---$check:単色化(T)
local chk = 0

local AL = 1 - rename_me_track0 * 0.01
local d = 2 * rename_me_track1
local rng = rename_me_track2
local bs = rename_me_track3
local w, h = obj.getpixel()

if d < -2 * h then
    d = -2 * h
end

local hd = h + d

obj.setoption("drawtarget", "tempbuffer", w, h + hd)

obj.draw(0, -hd * 0.5, 0)

obj.effect("反転", "上下反転", 1)
obj.effect("ぼかし", "範囲", rng, "サイズ固定", 1)

if col ~= nil then
    if chk == 0 then
        obj.effect("単色化", "color", col)
    else
        obj.effect("単色化", "color", 0)
        obj.effect("グラデーション", "color", col, "color2", col, "blend", 1)
    end
end
if d < 0 then
    obj.effect("斜めクリッピング", "角度", 180, "ぼかし", 0, "中心Y", -hd * 0.5)
end

obj.draw(0, hd * 0.5, 0, 1, AL)
obj.load("tempbuffer")
obj.cy = obj.cy - hd * bs * 0.005
