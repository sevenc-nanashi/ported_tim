--label:tim2\領域枠.anm\領域枠(角落ち)
---$track:画線幅
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 10

---$track:形状
---min=1
---max=4
---step=1
local rename_me_track1 = 1

---$track:切込量
---min=0
---max=5000
---step=0.1
local rename_me_track2 = 20

---$track:背景濃度
---min=0
---max=100
---step=0.1
local rename_me_track3 = 20

---$color:枠色
local col1 = 0xffffff

---$color:背景色
local col2 = 0xccccff

---$value:追加幅
local pw = 0

---$value:追加高さ
local ph = 0

---$value:基準
local base = { 0, 0 }

---$check:楕円
local rename_me_check0 = false

local function make_edge_del(wh, w1, h1, s, lw, fig, basefig)
    obj.load("figure", basefig, 0xffffff, 1.5 * wh)
    local wb = w1 - lw
    local hb = h1 - lw
    wb = ((wb > 0) and wb) or 0
    hb = ((hb > 0) and hb) or 0
    obj.drawpoly(-wb, -hb, 0, wb, -hb, 0, wb, hb, 0, -wb, hb, 0)
    obj.load("figure", fig, 0xffffff, s)
    obj.setoption("blend", "alpha_sub")
    obj.draw(w1, h1, 0, 0.5, 1, 0, 0, 0)
    obj.draw(-w1, h1, 0, 0.5, 1, 0, 0, 0)
    obj.draw(w1, -h1, 0, 0.5, 1, 0, 0, 0)
    obj.draw(-w1, -h1, 0, 0.5, 1, 0, 0, 0)
    obj.setoption("blend", 0)
end

local drawWaku = {}
drawWaku = {

    function(wh, w1, h1, s, lw, basefig)
        obj.load("figure", basefig, 0xffffff, 1.5 * wh)
        local wb = w1 - lw
        local hb = h1 - lw
        wb = ((wb > 0) and wb) or 0
        hb = ((hb > 0) and hb) or 0
        obj.drawpoly(-wb, -hb, 0, wb, -hb, 0, wb, hb, 0, -wb, hb, 0)
        obj.copybuffer("obj", "tmp")
        local wh0 = w1 + h1 - s - lw * 2 ^ 0.5
        obj.effect("斜めクリッピング", "中心X", -wh0, "ぼかし", 0, "角度", 135)
        obj.effect("斜めクリッピング", "中心X", -wh0, "ぼかし", 0, "角度", 45)
        obj.effect("斜めクリッピング", "中心X", wh0, "ぼかし", 0, "角度", -135)
        obj.effect("斜めクリッピング", "中心X", wh0, "ぼかし", 0, "角度", -45)
        obj.copybuffer("tmp", "obj")
    end,
    function(wh, w1, h1, s, lw, basefig)
        make_edge_del(wh, w1, h1, 4 * (s + lw), lw, "円", basefig)
    end,
    function(wh, w1, h1, s, lw, basefig)
        make_edge_del(wh, w1, h1, 4 * (s + lw), lw, "四角形", basefig)
    end,
    function(wh, w1, h1, s, lw, basefig)
        obj.load("figure", basefig, 0xffffff, 1.5 * wh)
        local wb = w1 - s + math.min(0, s - lw)
        local hb = h1 - lw
        wb = ((wb > 0) and wb) or 0
        hb = ((hb > 0) and hb) or 0
        obj.drawpoly(-wb, -hb, 0, wb, -hb, 0, wb, hb, 0, -wb, hb, 0)
        local wb = w1 - lw
        local hb = h1 - s + math.min(0, s - lw)
        wb = ((wb > 0) and wb) or 0
        hb = ((hb > 0) and hb) or 0
        obj.drawpoly(-wb, -hb, 0, wb, -hb, 0, wb, hb, 0, -wb, hb, 0)
        obj.load("figure", "円", 0xffffff, 8 * (s - lw))
        local wb = w1 - s
        local hb = h1 - s
        wb = ((wb > 0) and wb) or 0
        hb = ((hb > 0) and hb) or 0
        obj.draw(wb, hb, 0, 0.25, 1)
        obj.draw(wb, -hb, 0, 0.25, 1)
        obj.draw(-wb, hb, 0, 0.25, 1)
        obj.draw(-wb, -hb, 0, 0.25, 1)
    end,
}

local function atoshori(wh, col1)
    obj.copybuffer("cache:cache-Itiji", "tmp")
    obj.load("figure", "四角形", col1, wh + 10)
    obj.draw()
    obj.copybuffer("obj", "cache:cache-Itiji")
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.setoption("blend", 0)
end

local w, h = obj.getpixel()
local lw = rename_me_track0
local pt = rename_me_track1
local s = rename_me_track2
local backC = rename_me_track3 * 0.01
base = base or { 0, 0 }
if T_ryouikiwaku_w == nil then
    w, h = pw + w + 2 * lw, ph + h + 2 * lw
else
    w, h = T_ryouikiwaku_w + w + 2 * lw, T_ryouikiwaku_h + h + 2 * lw
end

w = ((w > 0) and w) or 0
h = ((h > 0) and h) or 0

local wh = math.max(w, h)
local w1 = w * 0.5
local h1 = h * 0.5

if pt == 4 then
    s = ((s < h1) and s) or h1
    s = ((s < w1) and s) or w1
end

local basefig
if rename_me_check0 then
    basefig = "円"
else
    basefig = "四角形"
end

--オリジナル保存
obj.copybuffer("cache:cache-ori", "obj")

--枠作成保存
obj.setoption("drawtarget", "tempbuffer", w + 10, h + 10)
drawWaku[pt](wh, w1, h1, s, lw, basefig)
atoshori(wh, col1)
obj.copybuffer("cache:cache-waku", "tmp")

--削除領域作成保存
obj.setoption("drawtarget", "tempbuffer", w + 10, h + 10)
drawWaku[pt](wh, w1, h1, s, 0, basefig)
atoshori(wh, col1)
obj.copybuffer("cache:cache-del", "tmp")

--描画
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("figure", "四角形", col2, wh)
obj.draw(0, 0, 0, 1, backC)

obj.copybuffer("obj", "cache:cache-ori")
obj.draw()

obj.copybuffer("obj", "cache:cache-waku")
obj.draw()

obj.copybuffer("obj", "cache:cache-del")
obj.setoption("blend", "alpha_sub")
obj.draw()

obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.cx = obj.cx + w * base[1] * 0.01
obj.cy = obj.cy + h * base[2] * 0.01
T_ryouikiwaku_w = nil
T_ryouikiwaku_h = nil
