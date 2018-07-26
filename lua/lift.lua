local request_method = ngx.var.request_method
local args = nil
local param = nil
local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/usr/share/adt.db")
local json = require("json")
if "GET" == request_method then
    args = ngx.req.get_uri_args()
    local getInfo = nil
    for row in db:nrows("SELECT item FROM config where name='lift'") do
        getInfo = row.item
    end
    ngx.say(getInfo)
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
    param = '{"status":' .. args["status"] .. ',"ip":"' .. args["ip"] .. '"}'
    local result = db:exec("UPDATE config SET item='" .. param .. "' WHERE name='lift'")
    local msg = ""

    local sock = ngx.socket.tcp()
    sock:connect("127.0.0.1", 10086)
    sock:send("AT+B RELOAD_CFG\r\n")
    sock:close()
    if (result == 0) then
        msg = '{"api":"/api/lift","state":0,"msg":"ok"}'
    else
        msg = '{"api":"/api/lift","state":1,"msg":"unknown error"}'
    end
    ngx.say(msg)
end
db:close()