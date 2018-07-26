local request_method = ngx.var.request_method
local args = nil
local param = nil

local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/usr/share/adt.db")
local json = require("json")

if "GET" == request_method then
    args = ngx.req.get_uri_args()
    local getresult = nil
    for row in db:nrows("SELECT item FROM config where name='address'") do
        getresult = row.item
    end
    ngx.say(getresult)
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
    param = '{"address":' .. args["address"] .. ',"ip":"' .. args["ip"] .. '","mask":"' .. args["mask"] .. '","gateway":"' .. args["gateway"] .. '","management":"' .. args["management"] .. '","guard":"' .. args["guard"] .. '"}'
    --ngx.say("UPDATE config SET item='" .. param .. "' WHERE name='address'")
    local result = db:exec("UPDATE config SET item='" .. param .. "' WHERE name='address'")
    local msg = ""
    local interface = nil
    interface = string.format("auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet static\naddress %s\ngateway %s\nnetmask %s\nnetwork 192.168.1.0\nbroadcast 192.168.1.255\ndns 192.168.1.1 8.8.8.8",args["ip"],args["gateway"],args["mask"])

    local interface_file=io.output("/etc/network/interfaces")
    io.write(interface)
    io.flush()
    io.close()
    if (result == 0) then
        msg = '{"api":"/api/address","state":0,"msg":"ok"}'
        --os.execute("reboot")
    else
        msg = '{"api":"/api/address","state":1,"msg":"unknown error"}'
    end
    ngx.say(msg)
    ngx.eof()
    os.execute("/etc/init.d/networking restart")
    local sock = ngx.socket.tcp()
    sock:connect("127.0.0.1", 10086)
    sock:send("AT+B RELOAD_CFG\r\n")
    sock:close()
end
db:close()
