--label:tim2
---$track:中心位置
---min=-20000
---max=20000
---step=0.1
local track_center_position = 0

---$track:出力幅％
---min=0
---max=5000
---step=0.1
local track_width_percent = 150

---$track:出力高％
---min=0
---max=5000
---step=0.1
local track_percent = 150

---$track:フェーズ
---min=-5000
---max=5000
---step=0.1
local track_phase = 0

---$value:速度方向(度)
local deg = 0

---$check:X反転配置
local reX = 0

---$check:Y反転配置
local reY = 0

---$check:水平シフト
local check0 = true

local CT = track_center_position
local OW = track_width_percent * 0.01
local OH = track_percent * 0.01
local SF = -track_phase * 0.01

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

if check0 then
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
