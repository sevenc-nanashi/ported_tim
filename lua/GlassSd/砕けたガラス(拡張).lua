--label:tim2\砕けたガラス.anm\砕けたガラス(拡張)
--track0:分割ﾊﾟﾀｰﾝ,0,4,1,1
--track1:限界ｻｲｽﾞ,5,1000,50
--track2:光散乱,1,100,30
--track3:拡大率,0,1000,100
--file:

kudaketagarasu_sppt = obj.track0
kudaketagarasu_spsiz = obj.track1
kudaketagarasu_LimL = (100 - obj.track2) * 0.01
kudaketagarasu_zoom = obj.track3 * 0.01
kudaketagarasu_file = file

-----------------------------------------------------------
