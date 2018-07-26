local request_method = ngx.var.request_method
local args = nil
local param = nil
local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/usr/share/adt.db")
local json = require("json")
if "GET" == request_method then
    args = ngx.req.get_uri_args()
    local getInfo = nil
    for row in db:nrows("SELECT item FROM config where name='datetime'") do
        getInfo = row.item
    end
    local t = io.popen('date +"%Z"')
    local time = t:read()
    local synch = 1
    local ret, data = pcall(json.decode, getInfo)
    if ret then
        synch = data["synch"]
    end
    param = '{"synch":'..synch..',"date":"' .. os.date("%Y-%m-%d %H:%M:%S")..'","timezone":"'..time..'"}'
    ngx.say(args['callbackfun'].."("..param..")")
    --ngx.say(param)
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
    param = '{"synch":' .. args["synch"] .. ',"datetime":"' .. args["datetime"] .. '"}'
    local result = db:exec("UPDATE config SET item='" .. param .. "' WHERE name='datetime'")
    local msg = ""
    if (result == 0) then
        msg = '{"api":"/api/datetime","state":0,"msg":"ok"}'
    else
        msg = '{"api":"/api/datetime","state":1,"msg":"unknown error"}'
    end
    ngx.say(msg)
    local sock = ngx.socket.tcp()
    sock:connect("127.0.0.1", 10086)
    sock:send("AT+B RELOAD_CFG\r\n")
    sock:close()
end
db:close()

