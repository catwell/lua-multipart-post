local ltn12 = require "ltn12"
local url = require "socket.url"

local _M = {}

_M.CHARSET = "UTF-8"
_M.LANGUAGE = ""

local fmt = function(p, ...)
    if select('#', ...) == 0 then
        return p
    else return string.format(p, ...) end
end

local tprintf = function(t, p, ...)
    t[#t+1] = fmt(p, ...)
end

local section_header = function(r, k, extra)
    tprintf(r, "content-disposition: form-data; name*=%s'%s'%s", _M.CHARSET, _M.LANGUAGE, url.escape(k))
    if extra.filename then
        tprintf(r, "; filename*=%s'%s'%s", _M.CHARSET, _M.LANGUAGE, url.escape(extra.filename))
    end
    if extra.content_type then
        tprintf(r, "\r\ncontent-type: %s", extra.content_type)
    end
    if extra.content_transfer_encoding then
        tprintf(
            r, "\r\ncontent-transfer-encoding: %s",
            extra.content_transfer_encoding
        )
    end
    tprintf(r, "\r\n\r\n")
end

local gen_boundary = function()
  local t = {"BOUNDARY-"}
  for i=2,17 do t[i] = string.char(math.random(65, 90)) end
  t[18] = "-BOUNDARY"
  return table.concat(t)
end

local encode = function(r, k, v, boundary)
    local _t = type(v)

    tprintf(r, "--%s\r\n", boundary)
    if _t == "string" then
        section_header(r, k, {})
    elseif _t == "table" then
        assert(v.data, "invalid input")
        local extra = {
            filename = v.filename or v.name,
            content_type = v.content_type or v.mimetype
                or "application/octet-stream",
            content_transfer_encoding = v.content_transfer_encoding or "binary",
        }
        section_header(r, k, extra)
    else
        error(string.format("unexpected type %s", _t))
    end
end

local encode_source = function(k, v, boundary)
    local r = {}
    encode(r, k, v, boundary)
    return ltn12.source.string(table.concat(r))
end

local data_len = function(d)
    local _t = type(d)

    if _t == "string" then
        return string.len(d)
    elseif _t == "table" then
        if type(d.data) == "string" then
            return string.len(d.data)
        end
        if d.len then return d.len end
        error("must provide data length for non-string datatypes")
    end
end

local content_length = function(t, boundary)
    local r = {}
    local data_length = 0
    for k, v in pairs(t) do
        encode(r, k, v, boundary)
        data_length = data_length + data_len(v)
        tprintf(r, "\r\n")
    end
    tprintf(r, "--%s--\r\n", boundary)

    return string.len(table.concat(r)) + data_length
end

local get_data_src = function(v)
    local _t = type(v)
    if v.source then
        return v.source
    elseif _t == "string" then
        return ltn12.source.string(v)
    elseif _t == "table" then
        _t = type(v.data)
        if _t == "string" then
            return ltn12.source.string(v.data)
        elseif _t == "table" then
            return ltn12.source.table(v.data)
        elseif _t == "userdata" then
            return ltn12.source.file(v.data)
        elseif _t == "function" then
            return v.data
        end
    end
    error("invalid input")
end

local set_ltn12_blksz = function(sz)
    assert(type(sz) == "number", "set_ltn12_blksz expects a number")
    ltn12.BLOCKSIZE = sz
end
_M.set_ltn12_blksz = set_ltn12_blksz

local source = function(t, boundary)
    local n = 1
    local sources = {}
    for k, v in pairs(t) do
        sources[n] = encode_source(k, t[k], boundary)
        sources[n+1] = get_data_src(v)
        sources[n+2] = ltn12.source.string("\r\n")
        n = n + 3
    end
    sources[n] = ltn12.source.string(string.format("--%s--\r\n", boundary))
    return ltn12.source.cat(table.unpack(sources))
end
_M.source = source

local gen_request = function(t)
    local boundary = gen_boundary()
    return {
        method = "POST",
        source = source(t, boundary),
        headers = {
            ["content-length"] = content_length(t, boundary),
            ["content-type"] = fmt("multipart/form-data; boundary=\"%s\"", boundary),
        },
    }
end
_M.gen_request = gen_request

return _M
