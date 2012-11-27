# multipart-post

## Presentation

HTTP Multipart Post helper that does just that.

## Dependencies

The module itself only depends on luasocket (for ltn12.)

Tests require cwtest, a JSON parser and the availability
of [httpbin.org](http://httpbin.org).

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

## Copyright

Copyright (c) 2012 Moodstocks SAS
