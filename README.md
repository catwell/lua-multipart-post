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

## Bugs

Non-ASCII part names and file names are not supported.
According to [RFC 2388](http://tools.ietf.org/html/rfc2388):

> Note that MIME headers are generally required to consist only of 7-
> bit data in the US-ASCII character set. Hence field names should be
> encoded according to the method in
> [RFC 2047](http://tools.ietf.org/html/rfc2047) if they contain
> characters outside of that set.

> The sending application MAY supply a
> file name; if the file name of the sender's operating system is not
> in US-ASCII, the file name might be approximated, or encoded using
> the method of [RFC 2231](http://tools.ietf.org/html/rfc2231).

## Copyright

- Copyright (c) 2012-2013 Moodstocks SAS
- Copyright (c) 2014-2016 Pierre Chapuis
