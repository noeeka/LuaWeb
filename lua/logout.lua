local request_method = ngx.var.request_method
local msg = nil
msg = '{"api":"/api/logout","state":0,"msg":"ok"}'
ngx.say(msg)