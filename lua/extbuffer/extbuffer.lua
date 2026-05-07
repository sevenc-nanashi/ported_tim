local tim2 = obj.module("tim2")

local M = {}
function M.read(id)
    local w, h = tim2.extbuffer_load_buffer_size(id)
    obj.clearbuffer("object", w, h)
    local data = obj.getpixeldata("object")
    tim2.extbuffer_load_buffer(id, data)
    obj.putpixeldata("object", data, w, h)
end

return M
