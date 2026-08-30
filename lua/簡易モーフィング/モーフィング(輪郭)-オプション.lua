--label:${ROOT_CATEGORY}\変形\@モーフィング
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
local line_color = 0xffffff

T_OUTLINE_MORPHING_RESULT = T_OUTLINE_MORPHING_RESULT or {}
T_OUTLINE_MORPHING_RESULT.line_width = track_width
T_OUTLINE_MORPHING_RESULT.rotation_degrees = track_rotation
T_OUTLINE_MORPHING_RESULT.threshold = track_threshold
T_OUTLINE_MORPHING_RESULT.point_offset = track_offset
T_OUTLINE_MORPHING_RESULT.line_color = line_color
if obj.getoption("script_name", 1, true) ~= "モーフィング(輪郭)-表示@モーフィング@tim.anm2" then
    T_OUTLINE_MORPHING_OPTIONS(T_OUTLINE_MORPHING_RESULT)
    T_OUTLINE_MORPHING_OPTIONS = nil
    T_OUTLINE_MORPHING_RESULT = nil
end
