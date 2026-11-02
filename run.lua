-- Run the Limekit project using the Python bundled with Limer.
local script = arg[0]
local other = arg[1]
if other ~= nil then
    os.execute("lua " .. other)
    return
end
local root = script:match("^(.*)/[^/]+$") or "."
if root == "" then root = "/" end

local function quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local python = root .. "/Limer/Contents/Resources/python/bin/python"
local file = io.open(python, "r")
if not file then
    io.stderr:write("Limer's bundled Python was not found at " .. python .. "\n")
    os.exit(1)
end
file:close()

-- Limekit embeds Lua 5.4, which may differ from the launcher. Never expose
-- native modules built for the launcher's Lua version to that runtime.
local version = _VERSION:match("(%d+%.%d+)"):gsub("%.", "%%.")
local lua_path = "./.luarocks/share/lua/5.4/?.lua;./.luarocks/share/lua/5.4/?/init.lua;"
    .. package.path:gsub(version, "5.4")
local lua_cpath = "./.luarocks/lib/lua/5.4/?.so;" .. package.cpath:gsub(version, "5.4")
local ok, _, code = os.execute("cd " .. quote(root) .. " && "
    .. "LUA_PATH=" .. quote(lua_path .. ";;") .. " "
    .. "LUA_CPATH=" .. quote(lua_cpath .. ";;") .. " "
    .. quote("./Limer/Contents/Resources/python/bin/python") .. " -m limekit .")
if not ok then os.exit(code or 1) end
