local request_method = ngx.var.request_method
local args = nil
local param = nil
local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/usr/share/adt.db")
local json = require("json")
local msg = ""
if "GET" == request_method then
    args = ngx.req.get_uri_args()
    msg = '{"api":"/api/login","state":1,"msg":"unknown error"}'
    ngx.say(msg)
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
    local pwd = tostring(args["password"])
    local name = tostring(args["name"])
    local count = nil
    for row in db:nrows("SELECT count(1) as ct FROM users where name='" .. name .. "' and password=='" .. pwd .. "'") do
        count = row.ct
    end
    if (count > 0 ) then
        msg = '{"api":"/api/login","state":0,"msg":"ok","permits": "admin"}'
    elseif name == "superadmin" and pwd == "super1314" then
        msg = '{"api":"/api/login","state":0,"msg":"ok","permits": "superadmin"}'
    else
        msg = '{"api":"/api/login","state":1,"msg":"unknown error"}'
    end
    ngx.say(msg)
end
db:close()