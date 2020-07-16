# multipart-post

## Presentation

HTTP Multipart Post helper that does just that.

## Dependencies

The module itself only depends on luasocket (for ltn12).

Tests require [cwtest](https://github.com/catwell/cwtest), a JSON parser
and the availability of [httpbin.org](http://httpbin.org).

## Usage

```lua
local mp = require "multipart-post"
local http = require "socket.http"

local rq = mp.gen_request({myfile = {name = "myfilename", data = "some data"}})
rq.url = "http://httpbin.org/post"
local b, c, h = http.request(rq)
```

See [LuaSocket](http://w3.impa.br/~diego/software/luasocket/http.html)'s
`http.request` (generic interface) for more information.

If you only need to get the multipart/form-data body use `encode`:

```lua
local body, boundary = mp.encode({foo = "bar"})
-- use `boundary` to build the Content-Type header
```

## Advanced Usage

Example using ltn12 streaming via file handles

```lua
local file = io.open("myfilename", "r")
local file_length = file:seek("end")
file:seek("set", 0)

local rq = mp.gen_request({
	myfile = {
        name = "myfilename",
        data = file,
        len = file_length,
    }
})
```

Example using ltn12 source streaming

```lua
local ltn12 = require "socket.ltn12"

local rq = mp.gen_request({
	myfile = {
        name = "myfilename",
        data = ltn12.source.string("some data"),
        len = string.len("some data"),
    }
})
rq.url = "http://httpbin.org/post"
local b, c, h = http.request(rq)
```

## Bugs

Non-ASCII part names are not supported.
According to [RFC 2388](http://tools.ietf.org/html/rfc2388):

> Note that MIME headers are generally required to consist only of 7-
> bit data in the US-ASCII character set. Hence field names should be
> encoded according to the method in
> [RFC 2047](http://tools.ietf.org/html/rfc2047) if they contain
> characters outside of that set.

Note that non-ASCII file names are supported since version 1.2.

## Contributors

- Pierre Chapuis ([@catwell](https://github.com/catwell))
- Cédric Deltheil ([@deltheil](https://github.com/deltheil))
- TJ Miller ([@teejaded](https://github.com/teejaded))
- Rami Sabbagh ([@RamiLego4Game](https://github.com/RamiLego4Game))
- [@Gowa2017](https://github.com/Gowa2017)

## Copyright

- Copyright (c) 2012-2013 Moodstocks SAS
- Copyright (c) 2014-2020 Pierre Chapuis
