local tim2 = obj.module("tim2")

local M = {}
function M.read(id)
    local data, w, h = tim2.extbuffer_load_buffer(id)
    obj.putpixeldata("object", data, w, h)
    tim2.extbuffer_free_buffer(data)
end

return M
