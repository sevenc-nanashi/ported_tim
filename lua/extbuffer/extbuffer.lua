local tim2 = obj.module("tim2")

local module = {}
function module.read_image(image_id)
    local w, h = tim2.extbuffer_load_buffer_size(image_id)
    obj.clearbuffer("object", w, h)
    local data = obj.getpixeldata("object")
    tim2.extbuffer_load_buffer(image_id, data)
    obj.putpixeldata("object", data, w, h)
end

return module
