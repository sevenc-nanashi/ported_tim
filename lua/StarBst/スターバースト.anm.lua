--label:tim2
--track0:強さ,0,400,10
--track1:拡散,0,200,100
--track2:しきい値,0,100,60
--track3:発光回転,-3600,3600,45

--value@col:発光色/col,0xffffff
--value@chk:オリジナル色発光/chk,1
--value@Lonly:光のみ/chk,0
--value@fig:形状[1-5],1
--value@blur:ぼかし,1

local w, h = obj.getpixel()

obj.copybuffer("cache:ori_img", "obj")

local deg = obj.track3

local sin = math.abs(math.sin(math.rad(deg)))
local cos = math.abs(math.cos(math.rad(deg)))

local w0 = w * cos + h * sin
local h0 = h * cos + w * sin

obj.setoption("drawtarget", "tempbuffer", w0, h0)
obj.draw(0, 0, 0, 1, 1, 0, 0, -deg)
obj.copybuffer("obj", "tmp")

obj.effect(
    "グロー",
    "強さ",
    obj.track0,
    "拡散",
    obj.track1,
    "しきい値",
    obj.track2,
    "ぼかし",
    blur,
    "type",
    fig,
    "光成分のみ",
    1,
    "no_color",
    chk,
    "color",
    col
)
if Lonly == 0 then
    obj.copybuffer("tmp", "cache:ori_img")
    obj.setoption("blend", 1)
else
    obj.setoption("drawtarget", "tempbuffer", w, h)
end
obj.draw(0, 0, 0, 1, 1, 0, 0, deg)

obj.load("tempbuffer")
obj.setoption("blend", 0)
