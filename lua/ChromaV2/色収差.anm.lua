--label:tim2\光効果
---$track:ズレ量
---min=0
---max=100
---step=0.1
local track_offset = 2

---$track:放射ボカシ
---min=0
---max=100
---step=0.1
local track_radial_blur = 2

---$track:焦点ズレ
---min=0
---max=100
---step=0.1
local track_focus_offset = 0

---$track:オリジナル
---min=0
---max=100
---step=0.1
local track_original = 0

---$check:位置ズレ補正
local reC = 1

---$select:色配置
---RGB=0
---GRB=1
---RBG=2
local select_color_layout = 0

---$track:ピンボケ量
---min=0
---max=100
---step=0.1
local track_defocus = 0

---$check:逆順
local check0 = false

local iox = obj.ox
local ioy = obj.oy
local icx = obj.cx
local icy = obj.cy
local reC2 = reC or 0

local mv = track_offset * 0.01
local bl = track_radial_blur
local Cnt = 2 * track_focus_offset * 0.01
local OrAlp = track_original * 0.01
local cpos2 = select_color_layout or 0
local pbl2 = track_defocus or 0

local mv_r, mv_g, mv_b
local p_r, p_g, p_b
if check0 then
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

local w, h = obj.getpixel()
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
