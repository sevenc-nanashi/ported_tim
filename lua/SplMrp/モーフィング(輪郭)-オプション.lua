--label:tim2\変形\モーフィング.anm
---$track:ライン幅
---min=0
---max=1000
---step=0.1
local track_width = 5

---$track:回転角
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:しきい値
---min=0
---max=254
---step=1
local track_threshold = 128

---$track:対応点ズレ
---min=-2000
---max=2000
---step=0.1
local track_offset = 0

---$color:ライン色
local col2 = 0xffffff

Out_morph_T = Out_morph_T or {}
Out_morph_T.Lw = track_width
Out_morph_T.Deg = track_rotation
Out_morph_T.T = track_threshold
Out_morph_T.SF = track_offset
Out_morph_T.col2 = col2
if obj.getoption("script_name", 1, true) ~= "モーフィング(輪郭)-表示@モーフィング" then
    Outlinemorphing_T(Out_morph_T)
    Outlinemorphing_T = nil
    Out_morph_T = nil
end
