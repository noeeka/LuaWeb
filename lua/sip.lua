local request_method = ngx.var.request_method
local args = nil
local param = nil

local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/usr/share/adt.db")
local json = require("json")

if "GET" == request_method then
    args = ngx.req.get_uri_args()
    local getresult = nil
    for row in db:nrows("SELECT item FROM config where name='sip'") do
        getresult = row.item
    end
    ngx.say(getresult)
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
    param = '{"username":"' .. args["username"] .. '","password":"' .. args["password"] .. '","server":"' .. args["sip"] .. '","receiver":"' .. args["receiver"] .. '","enable_register":"' .. args["enbale_reg"] .. '"}'
    --ngx.say("UPDATE config SET item='" .. param .. "' WHERE name='address'")
    local result = db:exec("UPDATE config SET item='" .. param .. "' WHERE name='sip'")
    local msg = ""
    local sock = ngx.socket.tcp()
    sock:connect("127.0.0.1", 10086)
    sock:send("AT+B RELOAD_CFG\r\n")
    sock:close()
    if (result == 0) then
        msg = '{"api":"/api/sip","state":0,"msg":"ok"}'
        --os.execute("reboot")
    else
        msg = '{"api":"/api/sip","state":1,"msg":"unknown error"}'
    end
    ngx.say(msg)
end
db:close()
