--label:tim2\モーフィング.anm\モーフィング(輪郭)-オプション
--track0:ライン幅,0,1000,5
--track1:回転角,-3600,3600,0
--track2:しきい値,0,254,128,1
--track3:対応点ｽﾞﾚ,-2000,2000,0
--value@col2:ライン色/col,0xffffff
Out_morph_T = Out_morph_T or {}
Out_morph_T.Lw = obj.track0
Out_morph_T.Deg = obj.track1
Out_morph_T.T = obj.track2
Out_morph_T.SF = obj.track3
Out_morph_T.col2 = col2
if obj.getoption("script_name", 1, true) ~= "モーフィング(輪郭)-表示@モーフィング" then
    Outlinemorphing_T(Out_morph_T)
    Outlinemorphing_T = nil
    Out_morph_T = nil
end
