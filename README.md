# multipart-post

## Presentation

HTTP Multipart Post helper that does just that.

## Dependencies

The module itself only depends on luasocket (for ltn12).

Tests require [cwtest](https://github.com/catwell/cwtest), a JSON parser
and the availability of [httpbin.org](http://httpbin.org).

## Usage

```lua
local mp = (require "multipart-post").gen_request
local H = (require "socket.http").request
local rq = mp{myfile = {name = "myfilename", data = "some data"}}
rq.url = "http://httpbin.org/post"
local b,c,h = H(rq)
```

See [LuaSocket](http://w3.impa.br/~diego/software/luasocket/http.html)'s
`http.request` (generic interface) for more information.

If you only need to get the multipart/form-data body use `encode`:

```lua
local enc = (require "multipart-post").encode
local body, boundary = enc{foo="bar"}
-- use `boundary` to build the Content-Type header
```

## Advanced Usage

Example using ltn12 streaming via file handles

```lua
local file = io.open("myfilename", "r")
local file_length = file:seek("end")
file:seek("set", 0)

local rq = mp{
	myfile = {name = "myfilename", data = file, len = file_length},
}
```

Example using ltn12 source streaming

```lua
ltn12 = require("socket.ltn12")

local rq = mp{
	myfile = {name = "myfilename", data = ltn12.source.string("some data"), len = string.len("some data")}
}
rq.url = "http://httpbin.org/post"
local b,c,h = H(rq)
```

## Copyright

- Copyright (c) 2012-2013 Moodstocks SAS
- Copyright (c) 2014-2016 Pierre Chapuis
