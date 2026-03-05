--label:tim2
---$track:ズレ量
---min=0
---max=100
---step=0.1
local rename_me_track0 = 2

---$track:放射ﾎﾞｶｼ
---min=0
---max=100
---step=0.1
local rename_me_track1 = 2

---$track:焦点ｽﾞﾚ
---min=0
---max=100
---step=0.1
local rename_me_track2 = 0

---$track:ｵﾘｼﾞﾅﾙ
---min=0
---max=100
---step=0.1
local rename_me_track3 = 0

---$check:位置ズレ補正
local reC = 1

---$value:色配置[0〜2]
local cpos = 0

---$value:ピンボケ量
local pbl = 0

---$check:逆順
local rename_me_check0 = true

local iox = obj.ox
local ioy = obj.oy
local icx = obj.cx
local icy = obj.cy
local reC2 = reC or 0

local mv = rename_me_track0 * 0.01
local bl = rename_me_track1
local Cnt = 2 * rename_me_track2 * 0.01
local OrAlp = rename_me_track3 * 0.01
local cpos2 = cpos or 0
local pbl2 = pbl or 0

local mv_r, mv_g, mv_b
local p_r, p_g, p_b
if rename_me_check0 then
    mv_r = 1 + (2 - Cnt) * mv
    mv_g = 1 + (1 - Cnt) * mv
    mv_b = 1 + -Cnt * mv
    p_r = pbl2 * math.abs(2 - Cnt) / 2
    p_g = pbl2 * math.abs(1 - Cnt) / 2
    p_b = pbl2 * math.abs(-Cnt) / 2
else
    mv_r = 1 + -Cnt * mv
    mv_g = 1 + (1 - Cnt) * mv
    mv_b = 1 + (2 - Cnt) * mv
    p_r = pbl2 * math.abs(-Cnt) / 2
    p_g = pbl2 * math.abs(1 - Cnt) / 2
    p_b = pbl2 * math.abs(2 - Cnt) / 2
end

if cpos2 == 1 then
    mv_r, mv_g = mv_g, mv_r
    p_r, p_g = p_g, p_r
elseif cpos2 == 2 then
    mv_b, mv_g = mv_g, mv_b
    p_b, p_g = p_g, p_b
end

local userdata, w, h = obj.getpixeldata()
obj.setoption("drawtarget", "tempbuffer", w, h)

obj.copybuffer("cache:ori_img", "obj")
obj.setoption("blend", 1)

--red処理
obj.effect("グラデーション", "color", 0xff0000, "color2", 0xff0000, "blend", 3)
obj.effect("ぼかし", "範囲", p_r, "サイズ固定", 1)
obj.effect("放射ブラー", "範囲", bl, "サイズ固定", 1)
obj.draw(0, 0, 0, mv_r)

--green処理
obj.copybuffer("obj", "cache:ori_img")
obj.effect("グラデーション", "color", 0x00ff00, "color2", 0x00ff00, "blend", 3)
obj.setoption("blend", 1)
obj.effect("ぼかし", "範囲", p_g, "サイズ固定", 1)
obj.effect("放射ブラー", "範囲", bl, "サイズ固定", 1)
obj.draw(0, 0, 0, mv_g)

--blue処理
obj.copybuffer("obj", "cache:ori_img")
obj.effect("グラデーション", "color", 0x0000ff, "color2", 0x0000ff, "blend", 3)
obj.setoption("blend", 1)
obj.effect("ぼかし", "範囲", p_b, "サイズ固定", 1)
obj.effect("放射ブラー", "範囲", bl, "サイズ固定", 1)
obj.draw(0, 0, 0, mv_b)

--オリジナル
obj.copybuffer("obj", "cache:ori_img")
obj.setoption("blend", 0)
obj.draw(0, 0, 0, 1, OrAlp)

obj.load("tempbuffer")
obj.setoption("blend", 0)

if reC2 == 1 then
    obj.ox = iox
    obj.oy = ioy
    obj.cx = icx
    obj.cy = icy
end
