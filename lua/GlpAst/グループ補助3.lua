--label:tim2\グループ補助.anm\グループ補助3
--track0:縦横比,-100,100,0
--track1:合成ﾓｰﾄﾞ,0,9,0
obj.aspect = obj.track0 * 0.01
obj.setoption("blend", math.floor(obj.track1))
