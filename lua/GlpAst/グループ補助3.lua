--label:tim2\グループ補助.anm
---$track:縦横比
---min=-100
---max=100
---step=0.1
local track_aspect_ratio = 0

---$track:合成ﾓｰﾄﾞ
---min=0
---max=9
---step=0.1
local track_blend_mode = 0

obj.aspect = track_aspect_ratio * 0.01
obj.setoption("blend", math.floor(track_blend_mode))
