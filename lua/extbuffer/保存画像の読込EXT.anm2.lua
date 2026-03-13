--label:tim2\オブジェクト制御\@一時保存読込EXT
---$track:読込先
---min=1
---max=1000
---step=1
local track_image_id = 0

---$embed
local extbuffer = require("extbuffer")
extbuffer.read(track_image_id)
