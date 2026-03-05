--label:tim2\グループ補助.anm
---$track:縦横比
---min=-100
---max=100
---step=0.1
local rename_me_track0 = 0

---$track:合成ﾓｰﾄﾞ
---min=0
---max=9
---step=0.1
local rename_me_track1 = 0

obj.aspect = rename_me_track0 * 0.01
obj.setoption("blend", math.floor(rename_me_track1))
