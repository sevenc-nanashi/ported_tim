--label:tim2\シーンチェンジ\シーンチェンジセットT.scn
---$track:ぼかし％
---min=0
---max=100
---step=0.1
local rename_me_track0 = 10

---$check:透過反転
local rename_me_check0 = true

local blur = 4096 * rename_me_track0 * 0.01
local T = obj.getvalue("scenechange")
local L = (4096 + 2 * blur) * T - blur

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", "alpha_sub")

obj.effect("単色化")
if rename_me_check0 then
    obj.effect("反転", "輝度反転", 1)
end
obj.effect("ルミナンスキー", "基準輝度", L, "ぼかし", blur, "type", 1)
obj.draw()

obj.copybuffer("obj", "tmp")
obj.setoption("drawtarget", "framebuffer")
obj.draw()
