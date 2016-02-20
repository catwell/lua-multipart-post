-- Quite minimal for now, I know ;)

local cwtest = require "cwtest"
local ltn12 = require "ltn12"
local H = (require "socket.http").request
local mp = (require "multipart-post").gen_request

local J
do -- Find a JSON parser
    local ok, json = pcall(require, "cjson")
    if not ok then ok, json = pcall(require, "json") end
    J = json.decode
    assert(ok and J, "no JSON parser found :(")
end

local T = cwtest.new()

T:start("tests")

local r = {}
local rq = mp{
    myfile = {name = "myfilename", data = "some data"},
    foo = "bar",
}
rq.url = "http://httpbin.org/post"
rq.sink = ltn12.sink.table(r)
local b, c, h = H(rq)

T:eq( c, 200 )

r = J(table.concat(r))

T:eq( r.files, {myfile = "some data"} )
T:eq( r.form, {foo = "bar"} )

T:done()

