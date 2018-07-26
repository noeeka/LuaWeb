local request_method = ngx.var.request_method
local args = nil
local param = nil
local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/usr/share/adt.db")
if "GET" == request_method then
    local json = require("json")
    for row in db:nrows("select * from config where name='ringtone'") do
        ngx.say(row.item)
    end
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
    local touch = nil
    if args["touch"] == "on" then
        touch = 0
    else
        touch = 1
    end
    param = '{"outdoor":"' .. args["outdoor"] .. '","inhouse":"' .. args["inhouse"] .. '","management":"' .. args["management"] .. '","duration":' .. args["duration"] .. ',"touch":' .. touch .. '}'
    local result = db:exec("UPDATE config SET item='" .. param .. "' WHERE name='ringtone'")
    local msg = ""

    local sock = ngx.socket.tcp()
    sock:connect("127.0.0.1", 10086)
    sock:send("AT+B RELOAD_CFG\r\n")
    sock:close()
    if (result == 0) then
        msg = '{"api":"/api/ringtone","state":0,"msg":"ok"}'
    else
        msg = '{"api":"/api/ringtone","state":1,"msg":"unknown error"}'
    end
    ngx.say(msg)
end