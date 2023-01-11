# multipart-post CHANGELOG

## v1.0

- First release.

## v1.1

- `encode` [autogenerates the boundary by default](https://github.com/catwell/lua-multipart-post/pull/1)

## v1.2

- Support non-ASCII file names
- [Use ltn12 chunked streaming to allow for sending large files](https://github.com/catwell/lua-multipart-post/pull/5)

## v1.3

- [Fix Lua 5.1 / LuaJIT support](https://github.com/catwell/lua-multipart-post/pull/6)

## 1.4

- [Boundary no longer enclosed in quotes in Content-Type header](https://github.com/catwell/lua-multipart-post/pull/7). This avoids bugs in some Web servers.
