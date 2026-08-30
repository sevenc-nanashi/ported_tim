--label:${ROOT_CATEGORY}\配置\@簡易リピーター
---$track:ｵﾌｾｯﾄ(S)
---min=-5000
---max=5000
---step=0.1
local track_time_offset_seconds = 0

---$track:送り(mS)
---min=-50000
---max=50000
---step=0.1
local track_frame_interval_ms = 40

---$track:ループ
---min=0
---max=1
---step=1
local track_loop = 1

---$track:α読込
---min=0
---max=1
---step=1
local track_alpha_load = 1

---$file:ファイル
local file_path = ""

T_REPEATER_FILE = file_path
T_REPEATER_START_TIME = track_time_offset_seconds + obj.time
T_REPEATER_TIME_STEP = track_frame_interval_ms * 0.001
T_REPEATER_LOOP = track_loop
T_REPEATER_LOAD_ALPHA = track_alpha_load
T_REPEATER_MODE = 1
