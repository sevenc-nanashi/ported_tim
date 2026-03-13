local M = {}
function M.is_last_chain()
    local match = obj.getoption("script_name", 1, true):match(".*@ストロークT@tim.anm2")
    return not match
end

return M
