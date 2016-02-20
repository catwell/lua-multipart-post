package = "multipart-post"
version = "1.1-1"

source = {
    url = "git://github.com/catwell/lua-multipart-post.git",
    branch = "v1.1",
}

description = {
    summary = "HTTP Multipart Post helper that does just that",
    detailed = [[
        HTTP Multipart Post helper that does just that.
    ]],
    homepage = "https://github.com/catwell/lua-multipart-post",
    license = "MIT/X11",
}

dependencies = {
    "lua >= 5.1",
    "luasocket",
}

build = {
    type = "none",
    install = { lua = { ["multipart-post"] = "multipart-post.lua" } },
    copy_directories = {},
}
