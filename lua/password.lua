local request_method = ngx.var.request_method
local args = nil
local param = nil

local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/usr/share/adt.db")
local json = require("json")

if "POST" == request_method then
    ngx.req.read_body()
	local data = {state=1}
	ngx.req.read_body()
	local data = ngx.req.get_body_data()
	if not data then
	   data = {state=1}
	   ngx.say(json.encode(data))
	   return
	end
	local data_unpack = json.decode(data)
	local name = data_unpack["name"]
	local old_pass = data_unpack["old_pass"]
	local new_pass = data_unpack["new_pass"]
    local result = 0
	local count = 0

	if "superadmin" == name then
    	result = db:exec("UPDATE users SET password='" .. new_pass .. "' WHERE name='admin'")
	else
		for row in db:nrows("SELECT count(1) as ct FROM users where name='admin' and password=='" .. old_pass .. "'") do
			count = row.ct
		end
		if count > 0 then
			result = db:exec("UPDATE users SET password='" .. new_pass .. "' WHERE name='admin' and password='"..old_pass.."'")
		else
			data = {state=1}
			ngx.say(json.encode(data))
			return
		end
	end
    for row in db:nrows("SELECT count(1) as ct FROM users where name='admin' and password=='" .. new_pass .. "'") do
        count = row.ct
    end

	data = {state=1}
	if (0 == result) and (count > 0) then
		data = {state=0}
	end
	ngx.say(json.encode(data))
end

