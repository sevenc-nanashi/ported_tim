--label:tim2\モーフィング.anm
---$track:ライン幅
---min=0
---max=1000
---step=0.1
local rename_me_track0 = 5

---$track:回転角
---min=-3600
---max=3600
---step=0.1
local rename_me_track1 = 0

---$track:しきい値
---min=0
---max=254
---step=1
local rename_me_track2 = 128

---$track:対応点ｽﾞﾚ
---min=-2000
---max=2000
---step=0.1
local rename_me_track3 = 0

---$color:ライン色
local col2 = 0xffffff

Out_morph_T = Out_morph_T or {}
Out_morph_T.Lw = rename_me_track0
Out_morph_T.Deg = rename_me_track1
Out_morph_T.T = rename_me_track2
Out_morph_T.SF = rename_me_track3
Out_morph_T.col2 = col2
if obj.getoption("script_name", 1, true) ~= "モーフィング(輪郭)-表示@モーフィング" then
    Outlinemorphing_T(Out_morph_T)
    Outlinemorphing_T = nil
    Out_morph_T = nil
end
