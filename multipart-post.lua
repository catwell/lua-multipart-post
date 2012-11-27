local ltn12 = require "ltn12"

local fmt = function(p,...)
  if select('#',...) == 0 then
    return p
  else return string.format(p,...) end
end

local tprintf = function(t,p,...)
  t[#t+1] = fmt(p,...)
end

local append_string = function(r,k,v)
  tprintf(r,"content-disposition: form-data; name=\"%s\"\r\n\r\n%s\r\n",k,v)
end

local append_data = function(r,k,fn,data,mimetype)
  tprintf(r,"content-disposition: form-data; name=\"%s\"; ",k)
  tprintf(r,"filename=\"%s\"\r\ncontent-type: %s\r\n\r\n",fn,mimetype)
  tprintf(r,data)
  tprintf(r,"\r\n")
end

local gen_boundary = function()
  local t = {"BOUNDARY-"}
  for i=2,17 do t[i] = string.char(math.random(65,90)) end
  t[18] = "-BOUNDARY"
  return table.concat(t)
end

local encode = function(t,boundary)
  local r = {}
  local _t
  for k,v in pairs(t) do
    tprintf(r,"--%s\r\n",boundary)
    _t = type(v)
    if _t == "string" then
      append_string(r,k,v)
    elseif _t == "table" then
      assert(v.name and v.data,"invalid input")
      append_data(r,k,v.name,v.data,v.mimetype or "application/octet-stream")
    else error(string.format("unexpected type %s",_t)) end
  end
  tprintf(r,"--%s--\r\n",boundary)
  return table.concat(r)
end

local gen_request = function(t)
  local boundary = gen_boundary()
  local s = encode(t,boundary)
  return {
    method = "POST",
    source = ltn12.source.string(s),
    headers = {
      ["content-length"] = #s,
      ["content-type"] = fmt("multipart/form-data; boundary=%s",boundary),
    },
  }
end

return {
  encode = encode,
  gen_request = gen_request,
}
