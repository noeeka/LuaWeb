#! /usr/bin/env lua
local _M = {}
--获取ifconfig
function _M.getMacInfo()
    file = io.popen("ifconfig")
    local mac = file:read()
    file:close()
    return mac;
end
return _M
--读文件