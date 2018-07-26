local request_method = ngx.var.request_method
local args = nil
local param = nil
local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/usr/share/adt.db")
local json = require("json")

if "GET" == request_method then
    args = ngx.req.get_uri_args()
    local getInfo = nil
    for row in db:nrows("SELECT item FROM config where name='administrator'") do
        getInfo = row.item
    end
    ngx.say(getInfo)
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
    param = '{"name":"' .. args["name"] .. '","password":"' .. args["password"] .. '"}'
    local result = db:exec("UPDATE config SET item='" .. param .. "' WHERE name='administrator'")
    local msg = ""
    if (result == 0) then
        msg = '{"api":"/api/administrator","state":0,"msg":"ok"}'
    else
        msg = '{"api":"/api/administrator","state":1,"msg":"unknown error"}'
    end
    ngx.say(msg)
end
db:close()