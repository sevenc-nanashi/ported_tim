--label:tim2
--track0:中心位置,-20000,20000,0
--track1:出力幅％,0,5000,150
--track2:出力高％,0,5000,150
--track3:フェーズ,-5000,5000,0
--value@deg:速度方向(度),0
--value@reX:X反転配置/chk,0
--value@reY:Y反転配置/chk,0
--check0:水平シフト,1;

local CT = obj.track0
local OW = obj.track1 * 0.01
local OH = obj.track2 * 0.01
local SF = -obj.track3 * 0.01

local w, h = obj.getpixel()

local SW = w * OW
local SH = h * OH

local TW = 2 * math.floor(SW * 0.5)
local TH = 2 * math.floor(SH * 0.5)

obj.setoption("drawtarget", "tempbuffer", TW, TH)
obj.setoption("blend", "alpha_add")

local px = CT * math.cos(deg * math.pi / 180)
local py = CT * math.sin(deg * math.pi / 180)
local dx = 180 * reX
local dy = 180 * reY

local SW2 = SW * 0.5
local SH2 = SH * 0.5

if obj.check0 then
    local ny1 = math.ceil((-py - SH2) / h - 0.5)
    local ny2 = math.floor((-py + SH2) / h + 0.5)
    for j = ny1, ny2 do
        local nx1 = math.ceil((-px - SW2) / w - SF * j - 0.5)
        local nx2 = math.floor((-px + SW2) / w - SF * j + 0.5)
        for i = nx1, nx2 do
            obj.draw(w * (i + SF * j) + px, h * j + py, 0, 1, 1, dy * j, dx * i, 0)
        end
    end
else
    local nx1 = math.ceil((-px - SW2) / w - 0.5)
    local nx2 = math.floor((-px + SW2) / w + 0.5)
    for i = nx1, nx2 do
        local ny1 = math.ceil((-py - SH2) / h - SF * i - 0.5)
        local ny2 = math.floor((-py + SH2) / h - SF * i + 0.5)
        for j = ny1, ny2 do
            obj.draw(w * i + px, h * (j + SF * i) + py, 0, 1, 1, dy * j, dx * i, 0)
        end
    end
end

obj.load("tempbuffer")
