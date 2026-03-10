--label:tim2\配置\簡易リピーター.anm
-- ---$track:X
-- ---min=-5000
-- ---max=5000
-- ---step=0.1
-- local track_x = 300
--
-- ---$track:Y
-- ---min=-5000
-- ---max=5000
-- ---step=0.1
-- local track_y = 0

--NOTE: track0、track1じゃないとsetanchorが壊れる

--track0:X,-5000,5000,300
--track1:Y,-5000,5000,0

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:拡大%
---min=00
---max=5000
---step=0.1
local track_scale_percent = 100

obj.setanchor("track", 0, "line")
repeater_dx = obj.getvalue(0)
repeater_dy = obj.getvalue(1)
repeater_dr = track_rotation
repeater_dk = track_scale_percent * 0.01
repeater_rep = 0
