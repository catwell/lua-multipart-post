local cwtest = require "cwtest"
local ltn12 = require "ltn12"
local H = (require "socket.http").request
local mp = (require "multipart-post").gen_request
local enc = (require "multipart-post").encode

local J
do -- Find a JSON parser
    local ok, json = pcall(require, "cjson")
    if not ok then ok, json = pcall(require, "json") end
    J = json.decode
    assert(ok and J, "no JSON parser found :(")
end

local file = io.open("testfile.tmp", "w+")
file:write("file data")
file:flush()
file:seek("set", 0)
local fsz = file:seek("end")
file:seek("set", 0)

local T = cwtest.new()

T:start("gen_request"); do
    local r = {}
    local rq = mp{
        myfile = {name = "myfilename", data = "some data"},
        diskfile = {name = "diskfilename", data = file, len = fsz},
        ltn12file =  {
            name = "ltn12filename",
            data = ltn12.source.string("ltn12 data"),
            len = string.len("ltn12 data")
        },
        foo = "bar",
    }

    rq.url = "http://httpbin.org/post"
    rq.sink = ltn12.sink.table(r)
    local _, c = H(rq)

    T:eq(c, 200)
    r = J(table.concat(r))

    T:eq(r.files, {
        myfile="some data",
        diskfile="file data",
        ltn12file="ltn12 data"
    })
    T:eq(r.form, {foo = "bar"})
end; T:done()

T:start("encode"); do
    local body, boundary = enc{foo="bar"}
    local r = {}

    local _, c = H{
        url = "http://httpbin.org/post",
        source = ltn12.source.string(body),
        method = "POST",
        sink = ltn12.sink.table(r),
        headers = {
            ["content-length"] = string.len(body),
            ["content-type"] = string.format(
                "multipart/form-data; boundary=\"%s\"", boundary
            ),
        },
    }
    T:eq(c, 200)
    r = J(table.concat(r))
    T:eq(r.form, {foo = "bar"})
end; T:done()

os.remove("testfile.tmp")
