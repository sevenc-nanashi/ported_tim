--label:tim2\未分類
---$track:サイズ
---min=0
---max=5000
---step=0.1
local size = 200

---$track:切込量
---min=0
---max=5000
---step=0.1
local cutting_size = 20

---$track:枠
---min=0
---max=5000
---step=0.1
local frame = 5000

---$color:色1
local col1 = 0xffffff

---$color:色2
local col2 = 0xccffcc

---$color:色3
local col3 = 0xffff00

-- おそらくAviUtl2で削除されたので消す
-- sampler="clip"/"dot"もやってみたけど差を感じなかったのでないものとする
-- ---$check:アンチエイリアス
-- local antialias = true

local MDP = function(a, b, c, d)
    obj.drawpoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, d.x, d.y, d.z)
end

local zoom = obj.getvalue("zoom") * 0.01
local L = size * zoom
local dL = cutting_size * zoom
local dw = frame * zoom

local Lh = L * 0.5
local Lhw = Lh - dL

local pos = {}
for i = 1, 6 do
    pos[i] = {}
end
pos[1] = {
    { x = -Lhw, y = -Lhw, z = -Lh },
    { x = Lhw,  y = -Lhw, z = -Lh },
    { x = Lhw,  y = Lhw,  z = -Lh },
    {
        x = -Lhw,
        y = Lhw,
        z = -Lh,
    },
}
pos[2] = {
    { z = -Lhw, y = -Lhw, x = Lh },
    { z = Lhw,  y = -Lhw, x = Lh },
    { z = Lhw,  y = Lhw,  x = Lh },
    {
        z = -Lhw,
        y = Lhw,
        x = Lh,
    },
}
pos[3] = {
    { x = Lhw,  y = -Lhw, z = Lh },
    { x = -Lhw, y = -Lhw, z = Lh },
    { x = -Lhw, y = Lhw,  z = Lh },
    {
        x = Lhw,
        y = Lhw,
        z = Lh,
    },
}
pos[4] = {
    { z = Lhw,  y = -Lhw, x = -Lh },
    { z = -Lhw, y = -Lhw, x = -Lh },
    { z = -Lhw, y = Lhw,  x = -Lh },
    {
        z = Lhw,
        y = Lhw,
        x = -Lh,
    },
}
pos[5] = {
    { x = -Lhw, z = Lhw,  y = -Lh },
    { x = Lhw,  z = Lhw,  y = -Lh },
    { x = Lhw,  z = -Lhw, y = -Lh },
    {
        x = -Lhw,
        z = -Lhw,
        y = -Lh,
    },
}
pos[6] = {
    { x = -Lhw, z = -Lhw, y = Lh },
    { x = Lhw,  z = -Lhw, y = Lh },
    { x = Lhw,  z = Lhw,  y = Lh },
    {
        x = -Lhw,
        z = Lhw,
        y = Lh,
    },
}

obj.load("figure", "四角形", col1, L - 2 * dL, dw)
-- obj.setoption("antialias", ANT)
for i = 1, 6 do
    MDP(pos[i][1], pos[i][2], pos[i][3], pos[i][4])
end

obj.load("figure", "四角形", col2, L)
-- obj.setoption("antialias", ANT)
for i = 1, 4 do
    local i2 = (i % 4) + 1
    local i3 = ((i2 - 2) % 4) + 1
    local i4 = 5 - i
    local i5 = 5 - i2
    MDP(pos[i][3], pos[i][2], pos[i2][1], pos[i2][4])
    MDP(pos[i][2], pos[i][1], pos[5][i4], pos[5][i5])
    MDP(pos[i][4], pos[i][3], pos[6][i2], pos[6][i])
end

obj.load("figure", "四角形", col3, L)
-- obj.setoption("antialias", ANT)
for i = 1, 4 do
    local i2 = 5 - i
    local i3 = ((i2 - 2) % 4) + 1
    local i4 = ((i - 2) % 4) + 1
    MDP(pos[5][i], pos[5][i], pos[i2][1], pos[i3][2])
    MDP(pos[6][i], pos[6][i], pos[i4][3], pos[i][4])
end